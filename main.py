from fastapi import FastAPI, HTTPException, BackgroundTasks, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse, FileResponse
from typing import List, Dict, Optional
import json
import logging
from datetime import datetime
import asyncio
import uuid

# Import our modules
from config import settings
from models import *
from legal_agents import legal_agents
from legal_database import legal_research_engine

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="AI Legal Decision-Making System",
    description="An AI-powered system for legal case management and decision making",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory storage (in production, use a proper database)
cases_db: Dict[str, LegalCase] = {}
websocket_connections: Dict[str, WebSocket] = {}

# Serve static files
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/", response_class=HTMLResponse)
async def home():
    """Serve the main web interface"""
    return FileResponse("templates/index.html")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

# ==============================================================================
# CASE MANAGEMENT ENDPOINTS
# ==============================================================================

@app.post("/api/cases", response_model=CaseResponse)
async def create_case(request: CreateCaseRequest):
    """Create a new legal case"""
    try:
        case = LegalCase(
            title=request.title,
            description=request.description,
            case_type=request.case_type,
            status=CaseStatus.INITIATED
        )
        
        cases_db[case.id] = case
        
        logger.info(f"Created new case: {case.id}")
        
        return CaseResponse(
            case=case,
            status="success",
            message=f"Case '{case.title}' created successfully"
        )
        
    except Exception as e:
        logger.error(f"Error creating case: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/cases", response_model=List[LegalCase])
async def get_all_cases():
    """Get all cases"""
    return list(cases_db.values())

@app.get("/api/cases/{case_id}", response_model=LegalCase)
async def get_case(case_id: str):
    """Get a specific case"""
    if case_id not in cases_db:
        raise HTTPException(status_code=404, detail="Case not found")
    
    return cases_db[case_id]

@app.delete("/api/cases/{case_id}")
async def delete_case(case_id: str):
    """Delete a case"""
    if case_id not in cases_db:
        raise HTTPException(status_code=404, detail="Case not found")
    
    del cases_db[case_id]
    return {"message": "Case deleted successfully"}

# ==============================================================================
# PARTY MANAGEMENT ENDPOINTS
# ==============================================================================

@app.post("/api/cases/{case_id}/parties", response_model=CaseResponse)
async def add_party(case_id: str, request: AddPartyRequest):
    """Add a party to a case"""
    if case_id not in cases_db:
        raise HTTPException(status_code=404, detail="Case not found")
    
    try:
        party = Party(
            name=request.name,
            party_type=request.party_type,
            description=request.description
        )
        
        case = cases_db[case_id]
        case.add_party(party)
        
        logger.info(f"Added party {party.name} to case {case_id}")
        
        return CaseResponse(
            case=case,
            status="success",
            message=f"Party '{party.name}' added successfully"
        )
        
    except Exception as e:
        logger.error(f"Error adding party: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/cases/{case_id}/parties", response_model=List[Party])
async def get_case_parties(case_id: str):
    """Get all parties in a case"""
    if case_id not in cases_db:
        raise HTTPException(status_code=404, detail="Case not found")
    
    return cases_db[case_id].parties

# ==============================================================================
# EVIDENCE MANAGEMENT ENDPOINTS
# ==============================================================================

@app.post("/api/cases/{case_id}/evidence", response_model=CaseResponse)
async def submit_evidence(case_id: str, request: SubmitEvidenceRequest):
    """Submit evidence to a case"""
    if case_id not in cases_db:
        raise HTTPException(status_code=404, detail="Case not found")
    
    try:
        evidence = Evidence(
            title=request.title,
            description=request.description,
            evidence_type=request.evidence_type,
            content=request.content,
            submitted_by=request.submitted_by
        )
        
        case = cases_db[case_id]
        case.add_evidence(evidence)
        case.status = CaseStatus.EVIDENCE_COLLECTION
        
        logger.info(f"Added evidence {evidence.title} to case {case_id}")
        
        return CaseResponse(
            case=case,
            status="success",
            message=f"Evidence '{evidence.title}' submitted successfully"
        )
        
    except Exception as e:
        logger.error(f"Error submitting evidence: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/cases/{case_id}/evidence", response_model=List[Evidence])
async def get_case_evidence(case_id: str):
    """Get all evidence in a case"""
    if case_id not in cases_db:
        raise HTTPException(status_code=404, detail="Case not found")
    
    return cases_db[case_id].evidence

# ==============================================================================
# LEGAL PROCEEDINGS ENDPOINTS
# ==============================================================================

@app.post("/api/cases/{case_id}/start-proceedings")
async def start_legal_proceedings(case_id: str, background_tasks: BackgroundTasks):
    """Start automated legal proceedings for a case"""
    if case_id not in cases_db:
        raise HTTPException(status_code=404, detail="Case not found")
    
    case = cases_db[case_id]
    
    if case.status == CaseStatus.VERDICT_RENDERED:
        raise HTTPException(status_code=400, detail="Case already has a verdict")
    
    if not case.evidence:
        raise HTTPException(status_code=400, detail="Cannot start proceedings without evidence")
    
    # Start proceedings in background
    background_tasks.add_task(conduct_case_proceedings, case_id)
    
    case.status = CaseStatus.CROSS_EXAMINATION
    
    return {
        "message": "Legal proceedings started",
        "case_id": case_id,
        "status": case.status
    }

async def conduct_case_proceedings(case_id: str):
    """Conduct the full legal proceedings (background task)"""
    try:
        case = cases_db[case_id]
        logger.info(f"Starting proceedings for case {case_id}")
        
        # Run the legal agents orchestrator
        updated_case = await legal_agents.conduct_case_proceedings(case)
        cases_db[case_id] = updated_case
        
        # Notify WebSocket clients
        await notify_websocket_clients(case_id, {
            "type": "case_update",
            "case_id": case_id,
            "status": updated_case.status,
            "message": "Legal proceedings completed"
        })
        
        logger.info(f"Completed proceedings for case {case_id}")
        
    except Exception as e:
        logger.error(f"Error in proceedings for case {case_id}: {str(e)}")
        if case_id in cases_db:
            cases_db[case_id].add_message(ConversationMessage(
                role=MessageRole.SYSTEM,
                content=f"Error in proceedings: {str(e)}",
                case_id=case_id
            ))

@app.post("/api/cases/{case_id}/cross-examine")
async def start_cross_examination(case_id: str, request: StartCrossExaminationRequest):
    """Start cross-examination for a specific party"""
    if case_id not in cases_db:
        raise HTTPException(status_code=404, detail="Case not found")
    
    case = cases_db[case_id]
    
    try:
        # Generate cross-examination questions
        questions = await legal_agents.cross_examiner.generate_cross_examination_questions(
            request.target_party,
            request.context,
            case.evidence
        )
        
        cross_exam_message = ConversationMessage(
            role=MessageRole.CROSS_EXAMINER,
            content=f"Cross-examination of {request.target_party}:\n{request.initial_question}\n\nFollow-up questions:\n" + 
                   "\n".join(f"{i+1}. {q}" for i, q in enumerate(questions)),
            case_id=case_id
        )
        
        case.add_message(cross_exam_message)
        case.status = CaseStatus.CROSS_EXAMINATION
        
        return {
            "message": "Cross-examination started",
            "questions": questions,
            "case_status": case.status
        }
        
    except Exception as e:
        logger.error(f"Error starting cross-examination: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/cases/{case_id}/verdict", response_model=VerdictResponse)
async def get_case_verdict(case_id: str):
    """Get the verdict for a case"""
    if case_id not in cases_db:
        raise HTTPException(status_code=404, detail="Case not found")
    
    case = cases_db[case_id]
    
    if not case.verdict:
        raise HTTPException(status_code=400, detail="No verdict available yet")
    
    # Generate final summary
    final_summary = f"""
    Case: {case.title}
    Verdict: {case.verdict.verdict_type.value}
    Confidence: {case.verdict.confidence_score:.2f}
    
    Decision Factors:
    """ + "\n".join(f"- {factor.factor}: {factor.reasoning}" for factor in case.verdict.decision_factors)
    
    return VerdictResponse(
        verdict=case.verdict,
        case_status=case.status,
        final_summary=final_summary
    )

# ==============================================================================
# CONVERSATION ENDPOINTS
# ==============================================================================

@app.post("/api/cases/{case_id}/messages")
async def send_message(case_id: str, request: MessageRequest):
    """Send a message in the case conversation"""
    if case_id not in cases_db:
        raise HTTPException(status_code=404, detail="Case not found")
    
    case = cases_db[case_id]
    
    try:
        message = ConversationMessage(
            role=request.role,
            content=request.content,
            case_id=case_id
        )
        
        case.add_message(message)
        
        # Generate AI response based on role
        if request.role == MessageRole.USER:
            ai_response = await generate_ai_response(case, request.content)
            case.add_message(ai_response)
        
        return {
            "message": "Message sent successfully",
            "conversation_length": len(case.conversation_history)
        }
        
    except Exception as e:
        logger.error(f"Error sending message: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/cases/{case_id}/messages", response_model=List[ConversationMessage])
async def get_case_messages(case_id: str):
    """Get all messages in a case"""
    if case_id not in cases_db:
        raise HTTPException(status_code=404, detail="Case not found")
    
    return cases_db[case_id].conversation_history

async def generate_ai_response(case: LegalCase, user_message: str) -> ConversationMessage:
    """Generate AI response to user message"""
    # Simple routing based on case status
    if case.status == CaseStatus.INITIATED:
        response = await legal_agents.prosecutor.generate_response(
            user_message,
            context=case.description
        )
        role = MessageRole.PROSECUTOR
    elif case.status == CaseStatus.EVIDENCE_COLLECTION:
        response = await legal_agents.defense.generate_response(
            user_message,
            context=case.description
        )
        role = MessageRole.DEFENSE
    else:
        response = await legal_agents.judge.generate_response(
            user_message,
            context=case.description
        )
        role = MessageRole.JUDGE
    
    return ConversationMessage(
        role=role,
        content=response,
        case_id=case.id
    )

# ==============================================================================
# LEGAL RESEARCH ENDPOINTS
# ==============================================================================

@app.post("/api/research/legal-question")
async def research_legal_question(request: Dict[str, str]):
    """Research a legal question using legal databases"""
    try:
        question = request.get("question", "")
        context = request.get("context", "")
        
        if not question:
            raise HTTPException(status_code=400, detail="Question is required")
        
        results = await legal_research_engine.research_legal_question(question, context)
        
        return {
            "results": results,
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Error in legal research: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/research/case-law")
async def search_case_law(request: Dict[str, str]):
    """Search case law"""
    try:
        query = request.get("query", "")
        jurisdiction = request.get("jurisdiction")
        
        if not query:
            raise HTTPException(status_code=400, detail="Query is required")
        
        results = await legal_research_engine.db_client.search_case_law(query, jurisdiction)
        
        return {
            "results": results,
            "query": query,
            "jurisdiction": jurisdiction,
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Error searching case law: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/research/verify-citation")
async def verify_citation(request: Dict[str, str]):
    """Verify a legal citation"""
    try:
        citation = request.get("citation", "")
        
        if not citation:
            raise HTTPException(status_code=400, detail="Citation is required")
        
        result = await legal_research_engine.db_client.verify_citation(citation)
        
        return result
        
    except Exception as e:
        logger.error(f"Error verifying citation: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# ==============================================================================
# WEBSOCKET ENDPOINTS
# ==============================================================================

@app.websocket("/ws/{case_id}")
async def websocket_endpoint(websocket: WebSocket, case_id: str):
    """WebSocket endpoint for real-time case updates"""
    await websocket.accept()
    websocket_connections[case_id] = websocket
    
    try:
        while True:
            data = await websocket.receive_text()
            message_data = json.loads(data)
            
            # Handle different message types
            if message_data.get("type") == "ping":
                await websocket.send_text(json.dumps({"type": "pong"}))
            elif message_data.get("type") == "get_case_status":
                if case_id in cases_db:
                    case = cases_db[case_id]
                    await websocket.send_text(json.dumps({
                        "type": "case_status",
                        "case_id": case_id,
                        "status": case.status,
                        "message_count": len(case.conversation_history)
                    }))
            
    except WebSocketDisconnect:
        logger.info(f"WebSocket disconnected for case {case_id}")
    finally:
        if case_id in websocket_connections:
            del websocket_connections[case_id]

async def notify_websocket_clients(case_id: str, message: Dict):
    """Notify WebSocket clients about case updates"""
    if case_id in websocket_connections:
        try:
            await websocket_connections[case_id].send_text(json.dumps(message))
        except Exception as e:
            logger.error(f"Error sending WebSocket message: {str(e)}")

# ==============================================================================
# UTILITY ENDPOINTS
# ==============================================================================

@app.get("/api/demo/create-sample-case")
async def create_sample_case():
    """Create a sample case for demonstration"""
    try:
        # Create sample case
        case = LegalCase(
            title="Smith vs. Johnson Contract Dispute",
            description="A contract dispute involving a breach of service agreement between Smith (plaintiff) and Johnson (defendant). Smith claims Johnson failed to deliver services as agreed, while Johnson claims Smith failed to make timely payments.",
            case_type="civil"
        )
        
        # Add parties
        plaintiff = Party(
            name="John Smith",
            party_type=PartyType.PLAINTIFF,
            description="Small business owner who contracted for marketing services"
        )
        defendant = Party(
            name="Sarah Johnson",
            party_type=PartyType.DEFENDANT,
            description="Marketing consultant who provided services"
        )
        
        case.add_party(plaintiff)
        case.add_party(defendant)
        
        # Add sample evidence
        evidence1 = Evidence(
            title="Service Agreement Contract",
            description="The original contract between Smith and Johnson",
            evidence_type=EvidenceType.DOCUMENT,
            content="Service Agreement dated January 1, 2024. Smith agrees to pay $5,000 for marketing services. Johnson agrees to deliver comprehensive marketing campaign within 60 days.",
            submitted_by=plaintiff.id
        )
        
        evidence2 = Evidence(
            title="Email Communications",
            description="Email chain between parties discussing project delays",
            evidence_type=EvidenceType.DIGITAL,
            content="Email from Johnson to Smith (Feb 15, 2024): 'Experiencing delays due to client revisions. Will need additional 2 weeks.' Smith reply: 'This is unacceptable. Contract clearly states 60 days maximum.'",
            submitted_by=defendant.id
        )
        
        evidence3 = Evidence(
            title="Payment Records",
            description="Bank records showing payment history",
            evidence_type=EvidenceType.DOCUMENT,
            content="Payment of $2,500 made on January 15, 2024. Second payment of $2,500 due February 15, 2024 - not received as of March 1, 2024.",
            submitted_by=plaintiff.id
        )
        
        case.add_evidence(evidence1)
        case.add_evidence(evidence2)
        case.add_evidence(evidence3)
        
        # Store case
        cases_db[case.id] = case
        
        return {
            "message": "Sample case created successfully",
            "case_id": case.id,
            "case": case
        }
        
    except Exception as e:
        logger.error(f"Error creating sample case: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/stats")
async def get_system_stats():
    """Get system statistics"""
    total_cases = len(cases_db)
    active_cases = len([c for c in cases_db.values() if c.status != CaseStatus.CLOSED])
    completed_cases = len([c for c in cases_db.values() if c.status == CaseStatus.VERDICT_RENDERED])
    
    return {
        "total_cases": total_cases,
        "active_cases": active_cases,
        "completed_cases": completed_cases,
        "websocket_connections": len(websocket_connections),
        "system_status": "operational"
    }

# ==============================================================================
# STARTUP AND SHUTDOWN EVENTS
# ==============================================================================

@app.on_event("startup")
async def startup_event():
    """Application startup"""
    logger.info("AI Legal Decision-Making System starting up...")
    logger.info(f"Debug mode: {settings.debug}")
    logger.info(f"OpenAI API configured: {bool(settings.openai_api_key)}")
    logger.info(f"Anthropic API configured: {bool(settings.anthropic_api_key)}")

@app.on_event("shutdown")
async def shutdown_event():
    """Application shutdown"""
    logger.info("AI Legal Decision-Making System shutting down...")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        debug=settings.debug,
        reload=settings.debug
    )