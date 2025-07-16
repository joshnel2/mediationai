from fastapi import FastAPI, HTTPException, BackgroundTasks, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict, Optional, Any
import json
import logging
from datetime import datetime, timedelta
import asyncio
import uuid
from pydantic import BaseModel, Field

# Import our enhanced workflow
from enhanced_dispute_workflow import dispute_manager, InvestigationPhase, EnhancedDispute
from config import settings

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Enhanced MediationAI API",
    description="AI-powered dispute resolution with private investigations and judicial decisions",
    version="2.0.0"
)

# CORS middleware for iOS app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request/Response Models
class CreateEnhancedDisputeRequest(BaseModel):
    title: str
    description: str
    category: str
    created_by: str
    participants: List[Dict[str, Any]]

class InvestigationMessageRequest(BaseModel):
    participant_id: str
    message: str

class DisputeStatusResponse(BaseModel):
    dispute_id: str
    title: str
    phase: str
    participants: List[Dict[str, Any]]
    investigations_complete: int
    has_final_resolution: bool
    timeline: List[Dict[str, Any]]

# WebSocket connections for real-time updates
websocket_connections: Dict[str, WebSocket] = {}

# ==============================================================================
# ENHANCED DISPUTE WORKFLOW ENDPOINTS
# ==============================================================================

@app.post("/api/v2/disputes")
async def create_enhanced_dispute(request: CreateEnhancedDisputeRequest):
    """Create a new dispute with enhanced investigation workflow"""
    try:
        # Validate participants
        if len(request.participants) < 2:
            raise HTTPException(status_code=400, detail="At least 2 participants required")
        
        # Ensure participants have required fields
        for participant in request.participants:
            if not all(key in participant for key in ['id', 'name', 'role']):
                raise HTTPException(status_code=400, detail="Participants must have id, name, and role")
        
        # Create dispute
        dispute = dispute_manager.create_dispute(
            title=request.title,
            description=request.description,
            category=request.category,
            created_by=request.created_by,
            participants=request.participants
        )
        
        logger.info(f"Created enhanced dispute: {dispute.id}")
        
        return {
            "status": "success",
            "message": "Enhanced dispute created successfully",
            "dispute_id": dispute.id,
            "phase": dispute.phase,
            "next_step": "Call /start-investigation to begin AI investigation",
            "dispute": dispute.dict()
        }
        
    except Exception as e:
        logger.error(f"Error creating enhanced dispute: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v2/disputes/{dispute_id}/start-investigation")
async def start_investigation(dispute_id: str):
    """Start the AI investigation phase"""
    try:
        result = await dispute_manager.start_investigation_phase(dispute_id)
        
        # Notify participants via WebSocket
        await notify_websocket_clients(dispute_id, {
            "type": "investigation_started",
            "phase": result["phase"],
            "message": "AI investigation has begun"
        })
        
        return {
            "status": "success",
            "message": "Investigation phase started",
            **result
        }
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error starting investigation: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v2/disputes/{dispute_id}/investigate/{participant_id}")
async def start_private_investigation(dispute_id: str, participant_id: str):
    """Start private investigation with a specific participant"""
    try:
        result = await dispute_manager.start_private_investigation(dispute_id, participant_id)
        
        # Notify only this participant via WebSocket
        await notify_participant_websocket(dispute_id, participant_id, {
            "type": "private_investigation_started",
            "conversation_id": result["conversation_id"],
            "message": result["message"]
        })
        
        return {
            "status": "success",
            "message": "Private investigation started",
            **result
        }
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error starting private investigation: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v2/disputes/{dispute_id}/investigate/{participant_id}/continue")
async def continue_investigation(dispute_id: str, participant_id: str, request: InvestigationMessageRequest):
    """Continue private investigation conversation"""
    try:
        result = await dispute_manager.continue_private_investigation(
            dispute_id, 
            participant_id, 
            request.message
        )
        
        # Notify only this participant via WebSocket
        await notify_participant_websocket(dispute_id, participant_id, {
            "type": "investigation_message",
            "conversation_id": result["conversation_id"],
            "message": result["message"],
            "is_complete": result["is_complete"]
        })
        
        # If investigation is complete, check if all investigations are done
        if result["is_complete"]:
            dispute_status = dispute_manager.get_dispute_status(dispute_id)
            if dispute_status["investigations_complete"] >= 2:
                # All investigations complete - notify all participants
                await notify_websocket_clients(dispute_id, {
                    "type": "all_investigations_complete",
                    "message": "All private investigations complete. AI is now conducting final analysis."
                })
        
        return {
            "status": "success",
            "message": "Investigation continued",
            **result
        }
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error continuing investigation: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v2/disputes/{dispute_id}/analyze")
async def conduct_final_analysis(dispute_id: str):
    """Conduct final analysis of all investigations"""
    try:
        result = await dispute_manager.conduct_final_analysis(dispute_id)
        
        # Notify all participants
        await notify_websocket_clients(dispute_id, {
            "type": "final_analysis_complete",
            "phase": result["phase"],
            "message": "AI has completed analysis. Ready for final decision."
        })
        
        return {
            "status": "success",
            "message": "Final analysis completed",
            **result
        }
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error conducting final analysis: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v2/disputes/{dispute_id}/render-decision")
async def render_final_decision(dispute_id: str):
    """Render final judicial decision"""
    try:
        result = await dispute_manager.render_final_decision(dispute_id)
        
        # Notify all participants of final resolution
        await notify_websocket_clients(dispute_id, {
            "type": "final_decision_rendered",
            "phase": result["phase"],
            "resolution": result["resolution"],
            "message": "Final decision has been rendered. Dispute is now resolved."
        })
        
        return {
            "status": "success",
            "message": "Final decision rendered",
            **result
        }
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error rendering final decision: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v2/disputes/{dispute_id}/status")
async def get_dispute_status(dispute_id: str):
    """Get current status of dispute"""
    try:
        status = dispute_manager.get_dispute_status(dispute_id)
        return {
            "status": "success",
            **status
        }
        
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        logger.error(f"Error getting dispute status: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v2/disputes/{dispute_id}/conversation/{participant_id}")
async def get_private_conversation(dispute_id: str, participant_id: str):
    """Get private conversation for a participant (only they can see it)"""
    try:
        dispute = dispute_manager.disputes.get(dispute_id)
        if not dispute:
            raise HTTPException(status_code=404, detail="Dispute not found")
        
        conversation = dispute.private_conversations.get(participant_id)
        if not conversation:
            raise HTTPException(status_code=404, detail="Private conversation not found")
        
        return {
            "status": "success",
            "conversation": conversation.dict()
        }
        
    except Exception as e:
        logger.error(f"Error getting private conversation: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v2/disputes/{dispute_id}/resolution")
async def get_final_resolution(dispute_id: str):
    """Get final resolution (only available once dispute is resolved)"""
    try:
        dispute = dispute_manager.disputes.get(dispute_id)
        if not dispute:
            raise HTTPException(status_code=404, detail="Dispute not found")
        
        if dispute.phase != InvestigationPhase.RESOLVED:
            raise HTTPException(status_code=400, detail="Dispute not yet resolved")
        
        return {
            "status": "success",
            "resolution": dispute.final_resolution,
            "phase": dispute.phase,
            "resolved_at": dispute.timeline[-1]["timestamp"]
        }
        
    except Exception as e:
        logger.error(f"Error getting final resolution: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# ==============================================================================
# WEBSOCKET ENDPOINTS
# ==============================================================================

@app.websocket("/ws/v2/{dispute_id}")
async def enhanced_websocket_endpoint(websocket: WebSocket, dispute_id: str):
    """Enhanced WebSocket endpoint for real-time updates"""
    await websocket.accept()
    
    connection_id = f"{dispute_id}_{uuid.uuid4()}"
    websocket_connections[connection_id] = websocket
    
    try:
        while True:
            data = await websocket.receive_text()
            message_data = json.loads(data)
            
            # Handle different message types
            if message_data.get("type") == "ping":
                await websocket.send_text(json.dumps({"type": "pong"}))
            elif message_data.get("type") == "get_status":
                try:
                    status = dispute_manager.get_dispute_status(dispute_id)
                    await websocket.send_text(json.dumps({
                        "type": "status_update",
                        **status
                    }))
                except Exception as e:
                    await websocket.send_text(json.dumps({
                        "type": "error",
                        "message": str(e)
                    }))
            elif message_data.get("type") == "join_as_participant":
                participant_id = message_data.get("participant_id")
                if participant_id:
                    # Store participant ID with connection
                    websocket_connections[connection_id] = {
                        "websocket": websocket,
                        "participant_id": participant_id
                    }
                    
                    await websocket.send_text(json.dumps({
                        "type": "joined",
                        "participant_id": participant_id
                    }))
    
    except WebSocketDisconnect:
        logger.info(f"WebSocket disconnected: {connection_id}")
    except Exception as e:
        logger.error(f"WebSocket error: {str(e)}")
    finally:
        if connection_id in websocket_connections:
            del websocket_connections[connection_id]

# ==============================================================================
# DEMO AND TESTING ENDPOINTS
# ==============================================================================

@app.get("/api/v2/demo/create-sample-dispute")
async def create_sample_enhanced_dispute():
    """Create a sample dispute for testing the enhanced workflow"""
    try:
        # Create sample participants
        participants = [
            {
                "id": "participant_1",
                "name": "John Doe",
                "role": "complainant",
                "email": "john@example.com"
            },
            {
                "id": "participant_2",
                "name": "Jane Smith",
                "role": "respondent",
                "email": "jane@example.com"
            }
        ]
        
        # Create dispute
        dispute = dispute_manager.create_dispute(
            title="Service Contract Dispute - Enhanced",
            description="Dispute over incomplete website development services. Client claims work was not completed as agreed, while contractor claims client changed requirements multiple times.",
            category="service",
            created_by="participant_1",
            participants=participants
        )
        
        return {
            "status": "success",
            "message": "Sample enhanced dispute created",
            "dispute_id": dispute.id,
            "participants": participants,
            "next_steps": [
                f"1. Call POST /api/v2/disputes/{dispute.id}/start-investigation",
                f"2. Call POST /api/v2/disputes/{dispute.id}/investigate/participant_1",
                f"3. Call POST /api/v2/disputes/{dispute.id}/investigate/participant_2",
                f"4. Continue conversations, then call analyze and render-decision"
            ]
        }
        
    except Exception as e:
        logger.error(f"Error creating sample dispute: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v2/demo/workflow-guide")
async def get_workflow_guide():
    """Get guide for the enhanced workflow"""
    return {
        "enhanced_workflow": {
            "1": {
                "step": "Create Dispute",
                "endpoint": "POST /api/v2/disputes",
                "description": "Create dispute with participants"
            },
            "2": {
                "step": "Start Investigation",
                "endpoint": "POST /api/v2/disputes/{id}/start-investigation",
                "description": "AI begins initial review and preparation"
            },
            "3": {
                "step": "Private Investigation - Party 1",
                "endpoint": "POST /api/v2/disputes/{id}/investigate/{participant_id}",
                "description": "AI conducts private investigation with first party"
            },
            "4": {
                "step": "Continue Investigation - Party 1",
                "endpoint": "POST /api/v2/disputes/{id}/investigate/{participant_id}/continue",
                "description": "Continue private conversation until complete"
            },
            "5": {
                "step": "Private Investigation - Party 2",
                "endpoint": "POST /api/v2/disputes/{id}/investigate/{participant_id}",
                "description": "AI conducts private investigation with second party"
            },
            "6": {
                "step": "Continue Investigation - Party 2",
                "endpoint": "POST /api/v2/disputes/{id}/investigate/{participant_id}/continue",
                "description": "Continue private conversation until complete"
            },
            "7": {
                "step": "Final Analysis",
                "endpoint": "POST /api/v2/disputes/{id}/analyze",
                "description": "AI analyzes all private investigations"
            },
            "8": {
                "step": "Render Decision",
                "endpoint": "POST /api/v2/disputes/{id}/render-decision",
                "description": "AI judge renders final binding decision"
            },
            "9": {
                "step": "Get Resolution",
                "endpoint": "GET /api/v2/disputes/{id}/resolution",
                "description": "Both parties can see the final resolution"
            }
        },
        "key_features": [
            "Private investigations with each party separately",
            "AI acts like a lawyer conducting cross-examination",
            "Only the final resolution is shared with both parties",
            "Real-time WebSocket updates for ongoing conversations",
            "Judge-like decision making based on private findings",
            "Transparent timeline tracking"
        ]
    }

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

async def notify_websocket_clients(dispute_id: str, message: Dict):
    """Notify all WebSocket clients about dispute updates"""
    disconnected_connections = []
    
    for connection_id, connection in websocket_connections.items():
        if dispute_id in connection_id:
            try:
                if isinstance(connection, dict):
                    websocket = connection["websocket"]
                else:
                    websocket = connection
                
                await websocket.send_text(json.dumps(message))
            except Exception as e:
                logger.error(f"Error sending WebSocket message: {str(e)}")
                disconnected_connections.append(connection_id)
    
    # Clean up disconnected connections
    for conn_id in disconnected_connections:
        if conn_id in websocket_connections:
            del websocket_connections[conn_id]

async def notify_participant_websocket(dispute_id: str, participant_id: str, message: Dict):
    """Notify specific participant via WebSocket"""
    for connection_id, connection in websocket_connections.items():
        if dispute_id in connection_id and isinstance(connection, dict):
            if connection.get("participant_id") == participant_id:
                try:
                    await connection["websocket"].send_text(json.dumps(message))
                except Exception as e:
                    logger.error(f"Error sending participant WebSocket message: {str(e)}")

# ==============================================================================
# HEALTH CHECK
# ==============================================================================

@app.get("/api/v2/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "version": "2.0.0",
        "timestamp": datetime.now().isoformat(),
        "active_disputes": len(dispute_manager.disputes),
        "websocket_connections": len(websocket_connections),
        "features": [
            "private_investigations",
            "judicial_decisions",
            "real_time_updates",
            "enhanced_workflow"
        ]
    }

# ==============================================================================
# STARTUP EVENTS
# ==============================================================================

@app.on_event("startup")
async def startup_event():
    """Application startup"""
    logger.info("Enhanced MediationAI API starting up...")
    logger.info(f"OpenAI API configured: {bool(settings.openai_api_key)}")
    logger.info("Enhanced workflow features enabled:")
    logger.info("- Private investigations with each party")
    logger.info("- AI judge decision making")
    logger.info("- Real-time WebSocket updates")
    logger.info("- Separate investigation phases")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "enhanced_mediation_api:app",
        host="0.0.0.0",
        port=8000,
        debug=True,
        reload=True
    )