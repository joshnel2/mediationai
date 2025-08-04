from fastapi import APIRouter, Request, HTTPException, Header, Depends
from sqlalchemy.orm import Session
from database import get_db
from betting_models import Transaction, UserWallet
from payment_service import payment_service
import logging

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/webhooks", tags=["webhooks"])

@router.post("/stripe")
async def stripe_webhook(
    request: Request,
    stripe_signature: str = Header(None),
    db: Session = Depends(get_db)
):
    """Handle Stripe webhooks for ACH and card payments"""
    try:
        payload = await request.body()
        
        # Verify webhook signature
        if not payment_service.verify_webhook_signature(
            payload, stripe_signature, "stripe"
        ):
            raise HTTPException(status_code=400, detail="Invalid signature")
        
        # Parse event
        import json
        event = json.loads(payload)
        
        # Handle different event types
        if event["type"] == "charge.succeeded":
            # ACH or card payment succeeded
            charge = event["data"]["object"]
            
            # Find the transaction
            transaction = db.query(Transaction).filter_by(
                external_id=charge["id"]
            ).first()
            
            if transaction and transaction.status == "pending":
                # Update transaction status
                transaction.status = "completed"
                
                # Update wallet balance
                wallet = db.query(UserWallet).filter_by(
                    id=transaction.wallet_id
                ).first()
                
                if wallet:
                    wallet.balance += transaction.amount
                    wallet.total_deposited += transaction.amount
                
                db.commit()
                logger.info(f"Payment completed: {charge['id']}")
        
        elif event["type"] == "charge.failed":
            # Payment failed
            charge = event["data"]["object"]
            
            transaction = db.query(Transaction).filter_by(
                external_id=charge["id"]
            ).first()
            
            if transaction:
                transaction.status = "failed"
                transaction.metadata = {
                    **transaction.metadata,
                    "failure_reason": charge.get("failure_message")
                }
                db.commit()
                logger.error(f"Payment failed: {charge['id']}")
        
        return {"status": "success"}
        
    except Exception as e:
        logger.error(f"Webhook error: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/plaid")
async def plaid_webhook(
    request: Request,
    db: Session = Depends(get_db)
):
    """Handle Plaid webhooks for bank account updates"""
    try:
        payload = await request.body()
        import json
        data = json.loads(payload)
        
        webhook_type = data.get("webhook_type")
        
        if webhook_type == "AUTH":
            # Handle auth webhooks (e.g., account verification)
            webhook_code = data.get("webhook_code")
            
            if webhook_code == "VERIFICATION_EXPIRED":
                # Handle expired verification
                logger.warning(f"Bank verification expired for item: {data.get('item_id')}")
        
        elif webhook_type == "TRANSACTIONS":
            # Handle transaction webhooks
            webhook_code = data.get("webhook_code")
            
            if webhook_code == "SYNC_UPDATES_AVAILABLE":
                # New transactions available
                logger.info(f"New transactions available for item: {data.get('item_id')}")
        
        return {"status": "success"}
        
    except Exception as e:
        logger.error(f"Plaid webhook error: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))