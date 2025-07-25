from fastapi import FastAPI, HTTPException, BackgroundTasks, WebSocket, WebSocketDisconnect, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import List, Dict, Optional, Any
import json
import logging
from datetime import datetime
import re

# Sentry (optional)
import sentry_sdk

# APNs push (optional)
from typing import Tuple
try:
    from apns2.client import APNsClient
    from apns2.payload import Payload
except ImportError:
    APNsClient = None  # type: ignore

import asyncio
import uuid
import os
from sqlalchemy.orm import Session

# Import our modules
from config import settings
from dispute_models import *
from mediation_agents import mediation_orchestrator
from contract_generator import contract_generator
from ai_cost_controller import ai_cost_controller
from database import get_db, init_db, User as DBUser, Dispute as DBDispute, Truth as DBTruth, Evidence as DBEvidence, Message as DBMessage, ChatMessageLog, ResolutionLog
from auth import get_password_hash, verify_password, create_access_token, get_current_user, get_current_user_optional
from upstash_client import get as upstash_get, set as upstash_set
try:
    import firebase_admin
    from firebase_admin import auth as fb_auth
except ImportError:
    fb_auth = None  # optional

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="MediationAI API",
    description="AI-powered dispute resolution backend for MediationAI iOS app",
    version="1.0.0"
)

# New: include social features (follow, clash rooms)
import social_api
app.include_router(social_api.router)

# CORS middleware for iOS app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for your iOS app
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database will be initialised lazily on startup to avoid cold-import connection issues on serverless platforms.

# WebSocket connections
websocket_connections: Dict[str, WebSocket] = {}

# ==============================================================================
# HEALTH CHECK ENDPOINT
# ==============================================================================

@app.get("/api/health")
async def health_check():
    """Health check endpoint to verify API is running"""
    return {
        "status": "healthy",
        "service": "MediationAI API",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat(),
        "features": {
            "ai_mediation": True,
            "legal_research": bool(settings.harvard_caselaw_api_key),
            "contract_generation": True,
            "cost_optimization": settings.enable_ai_cost_optimization
        }
    }

# ==============================================================================
# USER MANAGEMENT ENDPOINTS
# ==============================================================================

@app.post("/api/register")
async def register_user(request: UserRegistrationRequest, db: Session = Depends(get_db)):
    """Register a new user"""
    try:
        # Validate phone verification code
        expected = upstash_get(f"phone_code:{request.phoneNumber}")
        if expected is None or expected != request.verificationCode:
            raise HTTPException(status_code=400, detail="Invalid or expired verification code")

        # Optional password validation if provided
        if request.password:
            pw = request.password
            if len(pw) < 8 or not re.search(r"[0-9]", pw) or not re.search(r"[^A-Za-z0-9]", pw):
                raise HTTPException(status_code=400, detail="Password too weak. Must be ≥8 chars, include a number and symbol.")
            hashed_password = get_password_hash(pw)
        else:
            hashed_password = get_password_hash(str(uuid.uuid4()))  # random pw for phone-only login later

        # Ensure phone unique
        existing_user = db.query(DBUser).filter(DBUser.phone_number == request.phoneNumber).first()
        if existing_user:
            raise HTTPException(status_code=400, detail="Phone already registered")
        
        # Create new user
        db_user = DBUser(
            phone_number=request.phoneNumber,
            email=request.email,
            password_hash=hashed_password,
            display_name=request.display_name or request.phoneNumber,
            is_phone_verified=True
        )
        
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        
        # Create access token
        access_token = create_access_token(data={"sub": db_user.id})
        
        # Convert to response format
        user_response = User(
            id=db_user.id,
            email=db_user.email,
            displayName=db_user.display_name,
            hasUsedFreeDispute=db_user.has_used_free_dispute,
            totalDisputes=db_user.total_disputes,
            disputesWon=db_user.disputes_won,
            disputesLost=db_user.disputes_lost,
            createdAt=db_user.created_at.isoformat(),
            updatedAt=db_user.updated_at.isoformat(),
            faceIDEnabled=db_user.face_id_enabled,
            autoLoginEnabled=db_user.auto_login_enabled,
            notificationsEnabled=db_user.notifications_enabled
        )

        # --- NEW: Persist to Upstash ---
        try:
            # One-key-per-user
            upstash_set(f"user:{db_user.id}", user_response.dict())
            # Update flat users list (optional – best effort)
            users_list = upstash_get("users") or []
            users_list.append(user_response.dict())
            upstash_set("users", users_list)
        except Exception as up_err:
            logger.warning(f"Upstash sync failed: {up_err}")
        # --- END NEW ---
        
        return {
            "user": user_response,
            "access_token": access_token,
            "token_type": "bearer"
        }
        
    except Exception as e:
        logger.error(f"Registration failed: {str(e)}")
        raise HTTPException(status_code=400, detail="Registration failed")

# ---------------- Firebase phone signup ----------------
class FirebaseSignUpRequest(BaseModel):
    idToken: str
    displayName: str


@app.post("/api/auth/firebase-signup")
async def firebase_signup(request: FirebaseSignUpRequest, db: Session = Depends(get_db)):
    if fb_auth is None:
        raise HTTPException(status_code=500, detail="Firebase SDK not installed")
    try:
        decoded = fb_auth.verify_id_token(request.idToken)
        phone = decoded.get("phone_number")
        if not phone:
            raise ValueError("No phone number in token")
    except Exception as e:
        logger.error(f"Firebase token verify failed: {e}")
        raise HTTPException(status_code=400, detail="Invalid Firebase token")

    # Check if user exists
    user = db.query(DBUser).filter(DBUser.phone_number == phone).first()
    if not user:
        # Create user
        user = DBUser(
            phone_number=phone,
            display_name=request.displayName,
            password_hash=get_password_hash(str(uuid.uuid4())),
            is_phone_verified=True
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    access_token = create_access_token(data={"sub": user.id})
    user_response = User(
        id=user.id,
        phoneNumber=phone,
        displayName=user.display_name,
        isPhoneVerified=True
    )

    return {"user": user_response, "access_token": access_token, "token_type": "bearer"}

# ============================
# DEVICE REGISTRATION
# ============================

@app.post("/api/devices")
async def register_device(token: str, current_user: DBUser = Depends(get_current_user), db: Session = Depends(get_db)):
    """Save or update the APNs token for the authenticated user"""
    from database import Device  # local import to avoid circular

    existing = db.query(Device).filter(Device.apns_token == token).first()
    if existing:
        existing.user_id = current_user.id
    else:
        db.add(Device(user_id=current_user.id, apns_token=token))
    db.commit()
    return {"status": "success"}

# Helper to send a push – no-op if APNs not configured
def _send_push(apns_token: str, title: str, body: str):
    if not (settings.apns_key_base64 and APNsClient):
        return
    try:
        import base64, tempfile, os
        key_data = base64.b64decode(settings.apns_key_base64)
        with tempfile.NamedTemporaryFile(delete=False) as tmp:
            tmp.write(key_data)
            tmp_path = tmp.name
        client = APNsClient(tmp_path, key_id=settings.apns_key_id, team_id=settings.apns_team_id, use_sandbox=False)
        client.send_notification(apns_token, Payload(alert={"title": title, "body": body}, sound="default"))
    except Exception as e:
        logger.warning(f"APNs send failed: {e}")
    finally:
        try:
            os.remove(tmp_path)
        except Exception:
            pass

@app.post("/api/login")
async def login_user(request: UserLoginRequest, db: Session = Depends(get_db)):
    """Login user"""
    try:
        # Find user by email
        db_user = db.query(DBUser).filter(DBUser.email == request.email).first()
        if not db_user:
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        # Verify password
        if not verify_password(request.password, db_user.password_hash):
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        # Create access token
        access_token = create_access_token(data={"sub": db_user.id})
        
        # Convert to response format
        user_response = User(
            id=db_user.id,
            email=db_user.email,
            displayName=db_user.display_name,
            hasUsedFreeDispute=db_user.has_used_free_dispute,
            totalDisputes=db_user.total_disputes,
            disputesWon=db_user.disputes_won,
            disputesLost=db_user.disputes_lost,
            createdAt=db_user.created_at.isoformat(),
            updatedAt=db_user.updated_at.isoformat(),
            faceIDEnabled=db_user.face_id_enabled,
            autoLoginEnabled=db_user.auto_login_enabled,
            notificationsEnabled=db_user.notifications_enabled
        )
        
        return {
            "user": user_response,
            "access_token": access_token,
            "token_type": "bearer"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Login failed: {str(e)}")
        raise HTTPException(status_code=401, detail="Login failed")

@app.get("/api/me")
async def get_current_user_endpoint(current_user: DBUser = Depends(get_current_user)):
    """Return the authenticated user's details—used by iOS auto-login check"""
    user_response = User(
        id=current_user.id,
        email=current_user.email,
        displayName=current_user.display_name,
        hasUsedFreeDispute=current_user.has_used_free_dispute,
        totalDisputes=current_user.total_disputes,
        disputesWon=current_user.disputes_won,
        disputesLost=current_user.disputes_lost,
        createdAt=current_user.created_at.isoformat(),
        updatedAt=current_user.updated_at.isoformat(),
        faceIDEnabled=current_user.face_id_enabled,
        autoLoginEnabled=current_user.auto_login_enabled,
        notificationsEnabled=current_user.notifications_enabled
    )
    return {"user": user_response}

@app.get("/api/users/{user_id}")
async def get_user(user_id: str):
    """Get user details"""
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    
    return users_db[user_id]

# ==============================================================================
# DISPUTE MANAGEMENT ENDPOINTS
# ==============================================================================

@app.post("/api/disputes", response_model=DisputeResponse)
async def create_dispute(request: CreateDisputeRequest):
    """Create a new dispute"""
    try:
        # Verify user exists
        if request.created_by not in users_db:
            raise HTTPException(status_code=404, detail="User not found")
        
        dispute = Dispute(
            title=request.title,
            description=request.description,
            category=request.category,
            created_by=request.created_by,
            mediation_tone=request.mediation_tone,
            resolution_deadline=request.resolution_deadline
        )
        
        # Add creator as complainant
        user = users_db[request.created_by]
        complainant = DisputeParticipant(
            user_id=user.id,
            dispute_id=dispute.id,
            role=ParticipantRole.COMPLAINANT,
            username=user.username,
            email=user.email,
            full_name=user.full_name
        )
        
        dispute.add_participant(complainant)
        disputes_db[dispute.id] = dispute

        # If demo ghost requested, auto-add AI participant and optional first message
        if request.demoGhost:
            ghost_user = User(id=str(uuid.uuid4()), displayName="GhostAI", email=None, phoneNumber=None)
            users_db[ghost_user.id] = ghost_user
            ghost_participant = DisputeParticipant(
                user_id=ghost_user.id,
                dispute_id=dispute.id,
                role=ParticipantRole.RESPONDENT,
                username="GhostAI",
                email="ghost@demo.ai",
                full_name="Ghost AI"
            )
            dispute.add_participant(ghost_participant)
            # Ghost sends initial message
            opening = MediationMessage(
                dispute_id=dispute.id,
                sender_id=ghost_user.id,
                sender_type="ai_mediator",
                content="Hello, I'm your demo opponent. Let's resolve this!",
            )
            dispute.add_message(opening)
            _sync_dispute(dispute)
        
        # --- NEW: Persist dispute in Upstash ---
        _sync_dispute(dispute)
        # --- END NEW ---

        logger.info(f"Created dispute: {dispute.id}")
        
        return DisputeResponse(
            dispute=dispute,
            status="success",
            message=f"Dispute '{dispute.title}' created successfully"
        )
        
    except Exception as e:
        logger.error(f"Error creating dispute: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/disputes/{dispute_id}")
async def get_dispute(dispute_id: str):
    """Get a specific dispute"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    return disputes_db[dispute_id]

@app.get("/api/users/{user_id}/disputes", response_model=UserDisputesResponse)
async def get_user_disputes(user_id: str):
    """Get all disputes for a user"""
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    
    user_disputes = []
    for dispute in disputes_db.values():
        # Check if user is a participant
        is_participant = any(p.user_id == user_id for p in dispute.participants)
        
        if is_participant:
            # Count unread messages (simplified)
            unread_count = 0
            
            dispute_summary = DisputeSummary(
                id=dispute.id,
                title=dispute.title,
                category=dispute.category,
                status=dispute.status,
                created_at=dispute.created_at,
                updated_at=dispute.updated_at,
                participant_count=len(dispute.participants),
                evidence_count=len(dispute.evidence),
                unread_messages=unread_count,
                priority=dispute.priority
            )
            user_disputes.append(dispute_summary)
    
    # Sort by updated_at descending
    user_disputes.sort(key=lambda d: d.updated_at, reverse=True)
    
    unresolved_count = len([d for d in user_disputes if d.status != DisputeStatus.RESOLVED])
    
    return UserDisputesResponse(
        disputes=user_disputes,
        total_count=len(user_disputes),
        unresolved_count=unresolved_count
    )

@app.post("/api/disputes/{dispute_id}/join")
async def join_dispute(dispute_id: str, request: JoinDisputeRequest):
    """Join an existing dispute"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    if request.user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    
    dispute = disputes_db[dispute_id]
    user = users_db[request.user_id]
    
    # Check if user is already a participant
    for participant in dispute.participants:
        if participant.user_id == request.user_id:
            raise HTTPException(status_code=400, detail="User already joined this dispute")
    
    # Add user as participant
    participant = DisputeParticipant(
        user_id=user.id,
        dispute_id=dispute.id,
        role=request.role,
        username=user.username,
        email=user.email,
        full_name=user.full_name
    )
    
    dispute.add_participant(participant)
    
    # Send notification to other participants
    await notify_participants(dispute, f"{user.username} joined the dispute as {request.role}")
    
    return {
        "status": "success",
        "message": f"Successfully joined dispute as {request.role}",
        "dispute": dispute
    }

# ==============================================================================
# EVIDENCE MANAGEMENT ENDPOINTS
# ==============================================================================

@app.post("/api/disputes/{dispute_id}/evidence")
async def submit_evidence(dispute_id: str, request: SubmitEvidenceRequest):
    """Submit evidence to a dispute"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    if request.submitted_by not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    
    dispute = disputes_db[dispute_id]
    
    # Verify user is a participant
    is_participant = any(p.user_id == request.submitted_by for p in dispute.participants)
    if not is_participant:
        raise HTTPException(status_code=403, detail="User is not a participant in this dispute")
    
    evidence = Evidence(
        dispute_id=dispute_id,
        submitted_by=request.submitted_by,
        title=request.title,
        description=request.description,
        evidence_type=request.evidence_type,
        content=request.content
    )
    
    dispute.add_evidence(evidence)
    
    # --- NEW: sync dispute to Upstash ---
    _sync_dispute(dispute)
    # --- END NEW ---

    # Notify other participants
    user = users_db[request.submitted_by]
    await notify_participants(dispute, f"{user.username} submitted new evidence: {evidence.title}")
    
    logger.info(f"Evidence submitted to dispute {dispute_id}: {evidence.title}")
    
    return {
        "status": "success",
        "message": "Evidence submitted successfully",
        "evidence": evidence
    }

@app.get("/api/disputes/{dispute_id}/evidence")
async def get_dispute_evidence(dispute_id: str):
    """Get all evidence for a dispute"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    return disputes_db[dispute_id].evidence

# ==============================================================================
# MESSAGING ENDPOINTS
# ==============================================================================

@app.post("/api/disputes/{dispute_id}/messages")
async def send_message(dispute_id: str, request: SendMessageRequest, db: Session = Depends(get_db)):
    """Send a message in a dispute"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    if request.sender_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    
    dispute = disputes_db[dispute_id]
    
    # Verify user is a participant
    is_participant = any(p.user_id == request.sender_id for p in dispute.participants)
    if not is_participant:
        raise HTTPException(status_code=403, detail="User is not a participant in this dispute")
    
    # Create message
    message = MediationMessage(
        dispute_id=dispute_id,
        sender_id=request.sender_id,
        sender_type="user",
        content=request.content,
        message_type=request.message_type,
        is_private=request.is_private,
        recipient_id=request.recipient_id
    )
    
    dispute.add_message(message)

    # Persist to analytics table
    db_message = ChatMessageLog(
        id=message.id,
        dispute_id=dispute_id,
        sender_id=request.sender_id,
        sender_role="user",
        content=request.content,
        is_private=request.is_private,
        created_at=message.timestamp,
    )
    db.add(db_message)
    db.commit()
    
    # --- NEW: push message to Upstash chat list & update dispute snapshot ---
    try:
        chat_key = f"chat:{dispute_id}"
        chat_log = upstash_get(chat_key) or []
        chat_log.append(message.dict())
        upstash_set(chat_key, chat_log)
        _sync_dispute(dispute)
    except Exception as up_err:
        logger.warning(f"Upstash chat sync failed: {up_err}")
    # --- END NEW ---

    # Check if AI intervention is needed
    ai_response = await mediation_orchestrator.handle_dispute_message(dispute, message)
    if ai_response:
        dispute.add_message(ai_response)

        db_ai_msg = ChatMessageLog(
            id=ai_response.id,
            dispute_id=dispute_id,
            sender_id="ai",
            sender_role=ai_response.sender_type,
            content=ai_response.content,
            is_private=False,
            created_at=ai_response.timestamp,
        )
        db.add(db_ai_msg)
        db.commit()
    
    # Notify other participants via WebSocket
    await notify_websocket_clients(dispute_id, {
        "type": "new_message",
        "message": message.dict(),
        "ai_response": ai_response.dict() if ai_response else None
    })
    
    logger.info(f"Message sent in dispute {dispute_id}")
    
    return {
        "status": "success",
        "message": "Message sent successfully",
        "ai_response": ai_response.dict() if ai_response else None
    }

@app.get("/api/disputes/{dispute_id}/messages")
async def get_dispute_messages(dispute_id: str, limit: int = 50, for_user_id: str | None = None):
    """Return dispute messages visible to a specific user.

    Visibility rules:
    • Public messages (`is_private == False`) are always returned.
    • Private messages are returned *only* if the caller is the sender **or** the designated recipient.
    If `for_user_id` is not supplied the behaviour is unchanged (admin/debug use-case).
    """
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")

    all_messages = disputes_db[dispute_id].messages

    if for_user_id:
        visible = [
            m for m in all_messages
            if (not m.is_private) or (m.sender_id == for_user_id) or (m.recipient_id == for_user_id)
        ]
    else:
        visible = all_messages

    # Return most recent `limit` messages
    return visible[-limit:] if len(visible) > limit else visible

# ==============================================================================
# MEDIATION ENDPOINTS
# ==============================================================================

@app.post("/api/disputes/{dispute_id}/mediation/start")
async def start_mediation(dispute_id: str, background_tasks: BackgroundTasks):
    """Start AI-powered mediation for a dispute"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    dispute = disputes_db[dispute_id]
    
    if dispute.status != DisputeStatus.EVIDENCE_SUBMISSION:
        raise HTTPException(status_code=400, detail="Dispute not ready for mediation")
    
    # Start mediation in background
    background_tasks.add_task(conduct_mediation, dispute_id)
    
    return {
        "status": "success",
        "message": "Mediation started",
        "dispute_id": dispute_id
    }

async def conduct_mediation(dispute_id: str):
    """Conduct AI-powered mediation (background task)"""
    try:
        dispute = disputes_db[dispute_id]
        
        # Initiate mediation
        opening_message = await mediation_orchestrator.initiate_mediation(dispute)
        dispute.add_message(opening_message)
        
        # --- NEW: sync dispute to Upstash ---
        _sync_dispute(dispute)
        # --- END NEW ---

        # Notify participants
        await notify_websocket_clients(dispute_id, {
            "type": "mediation_started",
            "message": opening_message.dict()
        })
        
        logger.info(f"Mediation started for dispute {dispute_id}")
        
    except Exception as e:
        logger.error(f"Error in mediation for dispute {dispute_id}: {str(e)}")

@app.post("/api/disputes/{dispute_id}/mediation/propose")
async def propose_resolution(dispute_id: str, request: CreateProposalRequest, db: Session = Depends(get_db)):
    """Create a resolution proposal"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    dispute = disputes_db[dispute_id]
    
    # Create proposal
    proposal = ResolutionProposal(
        dispute_id=dispute_id,
        proposed_by=request.proposed_by,
        resolution_type=request.resolution_type,
        title=request.title,
        description=request.description,
        terms=request.terms,
        monetary_amount=request.monetary_amount,
        deadline=request.deadline
    )
    
    dispute.add_proposal(proposal)

    # Log proposal
    db_resolution = ResolutionLog(
        id=proposal.id,
        dispute_id=dispute_id,
        proposed_by=request.proposed_by,
        resolution_type=request.resolution_type.value if hasattr(request.resolution_type, 'value') else str(request.resolution_type),
        title=request.title,
        description=request.description,
        terms_json=json.dumps(request.terms),
        monetary_amount=request.monetary_amount,
        deadline=request.deadline,
        is_final=False,
        created_at=proposal.created_at,
    )
    db.add(db_resolution)
    db.commit()
    
    # Notify participants
    await notify_participants(dispute, f"New resolution proposal: {proposal.title}")
    
    return {
        "status": "success",
        "message": "Resolution proposal created",
        "proposal": proposal
    }

@app.post("/api/disputes/{dispute_id}/proposals/{proposal_id}/respond")
async def respond_to_proposal(dispute_id: str, proposal_id: str, request: AcceptProposalRequest, db: Session = Depends(get_db)):
    """Accept or reject a resolution proposal"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    dispute = disputes_db[dispute_id]
    
    # Find proposal
    proposal = None
    for p in dispute.proposals:
        if p.id == proposal_id:
            proposal = p
            break
    
    if not proposal:
        raise HTTPException(status_code=404, detail="Proposal not found")
    
    # Update proposal
    if request.accept:
        if request.user_id not in proposal.accepted_by:
            proposal.accepted_by.append(request.user_id)
        if request.user_id in proposal.rejected_by:
            proposal.rejected_by.remove(request.user_id)
    else:
        if request.user_id not in proposal.rejected_by:
            proposal.rejected_by.append(request.user_id)
        if request.user_id in proposal.accepted_by:
            proposal.accepted_by.remove(request.user_id)
    
    # Check if all participants have accepted
    participant_count = len(dispute.participants)
    if len(proposal.accepted_by) >= participant_count:
        # All accepted - resolve dispute
        dispute.final_resolution = proposal
        dispute.status = DisputeStatus.RESOLVED
        
        await notify_participants(dispute, f"Dispute resolved! Resolution: {proposal.title}")

        # Mark resolution as final in DB
        db_resolution_row = db.query(ResolutionLog).filter(ResolutionLog.id == proposal.id).first()
        if db_resolution_row:
            db_resolution_row.is_final = True
            db.commit()
    
    user = users_db[request.user_id]
    action = "accepted" if request.accept else "rejected"
    
    return {
        "status": "success",
        "message": f"Proposal {action} successfully",
        "proposal": proposal,
        "dispute_resolved": dispute.status == DisputeStatus.RESOLVED
    }

@app.post("/api/disputes/{dispute_id}/arbitration/start")
async def start_arbitration(dispute_id: str, background_tasks: BackgroundTasks):
    """Escalate dispute to AI arbitration"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    dispute = disputes_db[dispute_id]
    
    if dispute.status == DisputeStatus.RESOLVED:
        raise HTTPException(status_code=400, detail="Dispute already resolved")
    
    # Start arbitration in background
    background_tasks.add_task(conduct_arbitration, dispute_id)
    
    dispute.status = DisputeStatus.ESCALATED
    
    return {
        "status": "success",
        "message": "Arbitration started",
        "dispute_id": dispute_id
    }

async def conduct_arbitration(dispute_id: str):
    """Conduct AI arbitration (background task)"""
    try:
        dispute = disputes_db[dispute_id]
        
        # Get arbitration decision
        decision = await mediation_orchestrator.escalate_to_arbitration(dispute)
        dispute.add_proposal(decision)
        dispute.final_resolution = decision
        dispute.status = DisputeStatus.RESOLVED
        
        # Create system message
        arbitration_message = MediationMessage(
            dispute_id=dispute_id,
            sender_id="ai_arbitrator",
            sender_type="ai_arbitrator",
            content=f"Arbitration Decision: {decision.description}",
            message_type="arbitration"
        )
        
        dispute.add_message(arbitration_message)
        
        # --- NEW: sync dispute to Upstash ---
        _sync_dispute(dispute)
        # --- END NEW ---

        # Notify participants
        await notify_websocket_clients(dispute_id, {
            "type": "arbitration_decision",
            "decision": decision.dict(),
            "message": arbitration_message.dict()
        })
        
        logger.info(f"Arbitration completed for dispute {dispute_id}")
        
    except Exception as e:
        logger.error(f"Error in arbitration for dispute {dispute_id}: {str(e)}")

# ==============================================================================
# ANALYTICS ENDPOINTS
# ==============================================================================

@app.get("/api/disputes/{dispute_id}/analytics")
async def get_dispute_analytics(dispute_id: str):
    """Get analytics for a dispute"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    dispute = disputes_db[dispute_id]
    analytics = await mediation_orchestrator.analyst.analyze_dispute(dispute)
    
    return analytics

@app.get("/api/disputes/{dispute_id}/guidance")
async def get_process_guidance(dispute_id: str):
    """Get process guidance for a dispute"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    dispute = disputes_db[dispute_id]
    guidance = await mediation_orchestrator.get_process_guidance(dispute)
    
    return guidance

# ==============================================================================
# CONTRACT GENERATION ENDPOINTS
# ==============================================================================

@app.post("/api/disputes/{dispute_id}/contract/generate")
async def generate_contract(dispute_id: str, background_tasks: BackgroundTasks):
    """Generate a legally binding contract for the dispute resolution"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    dispute = disputes_db[dispute_id]
    
    # Check if dispute has a final resolution
    if not dispute.final_resolution:
        raise HTTPException(status_code=400, detail="Dispute must be resolved before generating contract")
    
    # Check if contract generation was requested
    if not getattr(dispute, 'requires_contract', False):
        raise HTTPException(status_code=400, detail="Contract generation not requested for this dispute")
    
    try:
        # Generate contract in background
        background_tasks.add_task(create_contract_task, dispute_id)
        
        return {
            "status": "success",
            "message": "Contract generation started",
            "dispute_id": dispute_id
        }
        
    except Exception as e:
        logger.error(f"Contract generation failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Contract generation failed")

async def create_contract_task(dispute_id: str):
    """Background task to generate contract"""
    try:
        dispute = disputes_db[dispute_id]
        resolution = dispute.final_resolution
        
        # Generate contract
        contract_text = await contract_generator.generate_contract(dispute, resolution)
        
        # Store contract in dispute
        dispute.contract_text = contract_text
        dispute.contract_generated_at = datetime.now()
        
        # Notify participants
        await notify_participants(dispute, "Legal contract has been generated and is ready for signature")
        
        logger.info(f"Contract generated for dispute {dispute_id}")
        
    except Exception as e:
        logger.error(f"Contract generation task failed: {str(e)}")

@app.get("/api/disputes/{dispute_id}/contract")
async def get_contract(dispute_id: str):
    """Get the generated contract for a dispute"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    dispute = disputes_db[dispute_id]
    
    if not hasattr(dispute, 'contract_text') or not dispute.contract_text:
        raise HTTPException(status_code=404, detail="Contract not generated yet")
    
    return {
        "dispute_id": dispute_id,
        "contract_text": dispute.contract_text,
        "generated_at": dispute.contract_generated_at,
        "status": "ready_for_signature"
    }

@app.post("/api/disputes/{dispute_id}/contract/sign")
async def sign_contract(dispute_id: str, request: SignContractRequest):
    """Sign the generated contract"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    dispute = disputes_db[dispute_id]
    
    if not hasattr(dispute, 'contract_text') or not dispute.contract_text:
        raise HTTPException(status_code=404, detail="Contract not generated yet")
    
    # Verify user is a participant
    is_participant = any(p.user_id == request.user_id for p in dispute.participants)
    if not is_participant:
        raise HTTPException(status_code=403, detail="User is not a participant in this dispute")
    
    # Add signature
    if not hasattr(dispute, 'contract_signatures'):
        dispute.contract_signatures = []
    
    signature = {
        "user_id": request.user_id,
        "signature": request.signature,
        "signed_at": datetime.now(),
        "ip_address": request.ip_address
    }
    
    dispute.contract_signatures.append(signature)
    
    # Check if all participants have signed
    if len(dispute.contract_signatures) >= len(dispute.participants):
        dispute.contract_fully_executed = True
        dispute.contract_execution_date = datetime.now()
        
        await notify_participants(dispute, "Contract has been fully executed by all parties")
    
    return {
        "status": "success",
        "message": "Contract signed successfully",
        "signatures_received": len(dispute.contract_signatures),
        "signatures_required": len(dispute.participants),
        "fully_executed": getattr(dispute, 'contract_fully_executed', False)
    }

# ==============================================================================
# ENHANCED RESOLUTION ENDPOINTS
# ==============================================================================

@app.post("/api/disputes/{dispute_id}/resolve")
async def resolve_dispute_with_contract(dispute_id: str, background_tasks: BackgroundTasks):
    """Resolve dispute and optionally generate contract"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    dispute = disputes_db[dispute_id]
    
    # Check if both parties have submitted evidence/truth
    if len(dispute.evidence) < 2:
        raise HTTPException(status_code=400, detail="Both parties must submit evidence before resolution")
    
    # Generate AI resolution
    try:
        if dispute.category in ["contract", "business", "payment"]:
            # Use arbitrator for formal disputes
            resolution = await mediation_orchestrator.escalate_to_arbitration(dispute)
        else:
            # Use mediator for general disputes
            resolution = await mediation_orchestrator.mediator.suggest_resolution(dispute)
        
        # Set as final resolution
        dispute.final_resolution = resolution
        dispute.status = DisputeStatus.RESOLVED
        dispute.resolved_at = datetime.now()
        
        # --- NEW: sync dispute to Upstash ---
        _sync_dispute(dispute)
        # --- END NEW ---

        # Generate contract if requested
        if getattr(dispute, 'requires_contract', False):
            background_tasks.add_task(create_contract_task, dispute_id)
            message = "Dispute resolved! Legal contract is being generated."
        else:
            message = "Dispute resolved successfully!"
        
        await notify_participants(dispute, message)
        
        return {
            "status": "success",
            "message": message,
            "resolution": resolution,
            "contract_pending": getattr(dispute, 'requires_contract', False)
        }
        
    except Exception as e:
        logger.error(f"Resolution failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Resolution process failed")

# ==============================================================================
# COST MONITORING ENDPOINTS
# ==============================================================================

@app.get("/api/disputes/{dispute_id}/cost-summary")
async def get_cost_summary(dispute_id: str):
    """Get cost summary for AI usage in a dispute"""
    if dispute_id not in disputes_db:
        raise HTTPException(status_code=404, detail="Dispute not found")
    
    try:
        cost_summary = ai_cost_controller.get_cost_summary(dispute_id)
        return {
            "dispute_id": dispute_id,
            "cost_summary": cost_summary,
            "cost_optimization_enabled": settings.enable_ai_cost_optimization,
            "limits": {
                "max_interventions": settings.max_ai_interventions_per_dispute,
                "max_tokens": settings.max_ai_response_tokens,
                "cooldown_minutes": settings.ai_intervention_cooldown_minutes
            }
        }
    except Exception as e:
        logger.error(f"Error getting cost summary: {str(e)}")
        raise HTTPException(status_code=500, detail="Unable to retrieve cost summary")

@app.get("/api/cost-settings")
async def get_cost_settings():
    """Get current cost optimization settings"""
    return {
        "cost_optimization_enabled": settings.enable_ai_cost_optimization,
        "max_interventions_per_dispute": settings.max_ai_interventions_per_dispute,
        "max_tokens_per_response": settings.max_ai_response_tokens,
        "cooldown_minutes": settings.ai_intervention_cooldown_minutes,
        "ai_model": settings.ai_model_preference,
        "caching_enabled": settings.enable_ai_response_caching,
        "estimated_cost_per_intervention": 0.05  # Rough estimate
    }

# ==============================================================================
# WEBSOCKET ENDPOINTS
# ==============================================================================

@app.websocket("/ws/{dispute_id}")
async def websocket_endpoint(websocket: WebSocket, dispute_id: str):
    """WebSocket endpoint for real-time dispute updates"""
    await websocket.accept()
    websocket_connections[dispute_id] = websocket
    
    try:
        while True:
            data = await websocket.receive_text()
            message_data = json.loads(data)
            
            # Handle different message types
            if message_data.get("type") == "ping":
                await websocket.send_text(json.dumps({"type": "pong"}))
            elif message_data.get("type") == "get_dispute_status":
                if dispute_id in disputes_db:
                    dispute = disputes_db[dispute_id]
                    await websocket.send_text(json.dumps({
                        "type": "dispute_status",
                        "dispute_id": dispute_id,
                        "status": dispute.status,
                        "message_count": len(dispute.messages)
                    }))
            
    except WebSocketDisconnect:
        logger.info(f"WebSocket disconnected for dispute {dispute_id}")
    finally:
        if dispute_id in websocket_connections:
            del websocket_connections[dispute_id]

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

async def notify_websocket_clients(dispute_id: str, message: Dict):
    """Notify WebSocket clients about dispute updates"""
    if dispute_id in websocket_connections:
        try:
            await websocket_connections[dispute_id].send_text(json.dumps(message))
        except Exception as e:
            logger.error(f"Error sending WebSocket message: {str(e)}")

async def notify_participants(dispute: Dispute, message: str):
    """Send notification to all participants in a dispute"""
    db: Session | None = None
    try:
        db = next(get_db())
    except Exception:
        db = None
    # Push notification via APNs (best effort)
    if hasattr(settings, "apns_key_id") and settings.apns_key_id:
        from database import Device  # avoid circular
        for p in dispute.participants:
            tokens = db.query(Device).filter(Device.user_id == p.user_id).all() if db else []
            for t in tokens:
                _send_push(t.apns_token, "Dispute Update", message)

    # Also log and send via WebSocket
    logger.info(f"Notification for dispute {dispute.id}: {message}")
    
    await notify_websocket_clients(dispute.id, {
        "type": "notification",
        "message": message,
        "timestamp": datetime.now().isoformat()
    })

# ----------------- Upstash sync helpers -----------------

def _upstash_save(key: str, value: Any):
    try:
        upstash_set(key, value)
    except Exception as up_err:
        logger.warning(f"Upstash set failed for {key}: {up_err}")

def _sync_dispute(dispute: Dispute):
    _upstash_save(f"dispute:{dispute.id}", dispute.dict())
# --------------------------------------------------------

# ==============================================================================
# DEMO ENDPOINTS
# ==============================================================================

@app.get("/api/demo/create-sample-dispute")
async def create_sample_dispute():
    """Create a sample dispute for demo purposes"""
    try:
        # Create sample users
        user1 = User(username="john_doe", email="john@example.com", full_name="John Doe")
        user2 = User(username="jane_smith", email="jane@example.com", full_name="Jane Smith")
        
        users_db[user1.id] = user1
        users_db[user2.id] = user2
        
        # Create sample dispute
        dispute = Dispute(
            title="Service Contract Dispute",
            description="Dispute over incomplete website development services. Client claims work was not completed as agreed, while contractor claims client changed requirements multiple times.",
            category="service",
            created_by=user1.id,
            mediation_tone=MediationTone.NEUTRAL
        )
        
        # Add participants
        complainant = DisputeParticipant(
            user_id=user1.id,
            dispute_id=dispute.id,
            role=ParticipantRole.COMPLAINANT,
            username=user1.username,
            email=user1.email,
            full_name=user1.full_name
        )
        
        respondent = DisputeParticipant(
            user_id=user2.id,
            dispute_id=dispute.id,
            role=ParticipantRole.RESPONDENT,
            username=user2.username,
            email=user2.email,
            full_name=user2.full_name
        )
        
        dispute.add_participant(complainant)
        dispute.add_participant(respondent)
        
        # Add sample evidence
        evidence1 = Evidence(
            dispute_id=dispute.id,
            submitted_by=user1.id,
            title="Original Contract",
            description="The signed contract outlining the website development scope and timeline",
            evidence_type=EvidenceType.DOCUMENT,
            content="Website development contract signed on March 1, 2024. Scope includes: responsive design, 5 pages, contact form, and basic SEO. Deadline: April 15, 2024. Total cost: $3,000."
        )
        
        evidence2 = Evidence(
            dispute_id=dispute.id,
            submitted_by=user2.id,
            title="Client Email Changes",
            description="Email chain showing client's additional requests and scope changes",
            evidence_type=EvidenceType.TEXT,
            content="Email from client on March 15: 'Can we add a blog section and e-commerce functionality?' Email from March 20: 'Also need mobile app integration and social media feeds.' These were not in the original scope."
        )
        
        dispute.add_evidence(evidence1)
        dispute.add_evidence(evidence2)
        
        # Add sample messages
        message1 = MediationMessage(
            dispute_id=dispute.id,
            sender_id=user1.id,
            sender_type="user",
            content="I paid $3,000 for a website that was supposed to be completed by April 15th. It's now May and I still don't have a working website.",
            message_type="text"
        )
        
        message2 = MediationMessage(
            dispute_id=dispute.id,
            sender_id=user2.id,
            sender_type="user",
            content="The original scope was completed on time. The client kept asking for additional features that weren't in the contract. I've spent extra time trying to accommodate these requests.",
            message_type="text"
        )
        
        dispute.add_message(message1)
        dispute.add_message(message2)
        
        disputes_db[dispute.id] = dispute
        
        return {
            "status": "success",
            "message": "Sample dispute created",
            "dispute_id": dispute.id,
            "users": [user1.dict(), user2.dict()],
            "dispute": dispute.dict()
        }
        
    except Exception as e:
        logger.error(f"Error creating sample dispute: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "disputes_count": len(disputes_db),
        "users_count": len(users_db)
    }

@app.get("/api/admin/users")
async def admin_get_all_users():
    """Return user snapshots stored in Upstash Redis under key 'users'. This avoids DB connectivity issues."""
    users_data = upstash_get("users")
    if users_data is None:
        return {"users": [], "source": "upstash", "note": "No data found"}
    return {"users": users_data, "source": "upstash"}

# ==============================================================================
# STARTUP EVENTS
# ==============================================================================

@app.on_event("startup")
async def startup_event():
    """Application startup"""
    logger.info("MediationAI API starting up...")
    logger.info(f"OpenAI API configured: {bool(settings.openai_api_key)}")
    logger.info(f"Anthropic API configured: {bool(settings.anthropic_api_key)}")

    # Init Sentry if DSN provided
    if settings.sentry_dsn:
        sentry_sdk.init(dsn=settings.sentry_dsn, traces_sample_rate=0.2)
        logger.info("Sentry initialised")

    # Initialize DB but make sure any failure doesn't bring the whole service down
    try:
        init_db()
    except Exception as db_init_err:
        logger.error(f"Database initialisation failed: {db_init_err}")
        # Don't raise – we'll fallback to in-memory dicts so read-only endpoints still work

# ============================
# PHONE VERIFICATION
# ============================

@app.post("/api/auth/request-code")
async def request_verification_code(phone: str):
    """Generate a 6-digit code and send via SMS (stubbed)"""
    import random
    code = f"{random.randint(0, 999999):06d}"

    # Store in Upstash with 10-minute expiry
    try:
        upstash_set(f"phone_code:{phone}", code, ex=600)
    except Exception as e:
        logger.warning(f"Failed to save phone code: {e}")

    # TODO: integrate Twilio. For now just log.
    logger.info(f"[DEV] Verification code for {phone}: {code}")

    return {"status": "sent"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "mediation_api:app",
        host="0.0.0.0",
        port=8000,
        debug=True,
        reload=True
    )