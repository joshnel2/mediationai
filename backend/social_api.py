from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect
from sqlalchemy.orm import Session
from typing import Dict, List
from datetime import datetime

from database import get_db, User as DBUser
from auth import get_current_user
from social_models import Follow, ClashRoom

router = APIRouter(prefix="/api")

# ----------------------------
# FOLLOW / UNFOLLOW ENDPOINTS
# ----------------------------

@router.post("/follow/{target_user_id}")
async def follow_user(target_user_id: str, current_user: DBUser = Depends(get_current_user), db: Session = Depends(get_db)):
    if target_user_id == current_user.id:
        raise HTTPException(status_code=400, detail="You cannot follow yourself")

    existing = db.query(Follow).filter(Follow.follower_id == current_user.id, Follow.followee_id == target_user_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Already following this user")

    # Verify target exists
    if not db.query(DBUser).filter(DBUser.id == target_user_id).first():
        raise HTTPException(status_code=404, detail="Target user not found")

    follow = Follow(follower_id=current_user.id, followee_id=target_user_id)
    db.add(follow)
    db.commit()
    return {"status": "following"}


@router.delete("/follow/{target_user_id}")
async def unfollow_user(target_user_id: str, current_user: DBUser = Depends(get_current_user), db: Session = Depends(get_db)):
    follow = db.query(Follow).filter(Follow.follower_id == current_user.id, Follow.followee_id == target_user_id).first()
    if not follow:
        raise HTTPException(status_code=404, detail="Not following this user")

    db.delete(follow)
    db.commit()
    return {"status": "unfollowed"}


@router.get("/users/{user_id}/followers")
async def get_followers(user_id: str, db: Session = Depends(get_db)):
    followers = db.query(Follow).filter(Follow.followee_id == user_id).all()
    return {"count": len(followers), "followers": [f.follower_id for f in followers]}


@router.get("/users/{user_id}/following")
async def get_following(user_id: str, db: Session = Depends(get_db)):
    following = db.query(Follow).filter(Follow.follower_id == user_id).all()
    return {"count": len(following), "following": [f.followee_id for f in following]}

# ----------------------------
# CLASH ROOM ENDPOINTS
# ----------------------------

@router.post("/clashes")
async def create_clash(streamer_a_id: str, streamer_b_id: str, current_user: DBUser = Depends(get_current_user), db: Session = Depends(get_db)):
    # Only allow creation if current user is one of the streamers
    if current_user.id not in (streamer_a_id, streamer_b_id):
        raise HTTPException(status_code=403, detail="You must be one of the participants to create a clash")

    # Check both users exist
    for uid in (streamer_a_id, streamer_b_id):
        if not db.query(DBUser).filter(DBUser.id == uid).first():
            raise HTTPException(status_code=404, detail=f"User {uid} not found")

    clash = ClashRoom(streamer_a_id=streamer_a_id, streamer_b_id=streamer_b_id)
    db.add(clash)
    db.commit()
    db.refresh(clash)
    return {"clash_id": clash.id, "status": clash.status}


@router.get("/clashes/live")
async def list_live_clashes(db: Session = Depends(get_db)):
    live_rooms = db.query(ClashRoom).filter(ClashRoom.status == "live").order_by(ClashRoom.created_at.desc()).all()
    return [
        {
            "clash_id": room.id,
            "streamerA": room.streamer_a_id,
            "streamerB": room.streamer_b_id,
            "viewerCount": room.viewer_count,
            "startedAt": room.created_at.isoformat()
        }
        for room in live_rooms
    ]


# ----------------------------
# WEBSOCKET FOR SPECTATORS
# ----------------------------

clash_ws_connections: Dict[str, List[WebSocket]] = {}

@router.websocket("/ws/clash/{clash_id}")
async def clash_websocket_endpoint(websocket: WebSocket, clash_id: str):
    await websocket.accept()
    connections = clash_ws_connections.setdefault(clash_id, [])
    connections.append(websocket)

    try:
        while True:
            # Expect small reaction payloads from spectators {"emoji":"🔥"}
            data = await websocket.receive_json()
            # Broadcast to everyone in the same clash
            for conn in connections:
                if conn is not websocket:
                    await conn.send_json({"type": "reaction", "data": data})
    except WebSocketDisconnect:
        connections.remove(websocket)