from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect, BackgroundTasks
from sqlalchemy.orm import Session
from typing import Dict, List
from datetime import datetime, timedelta
import random, string
from sqlalchemy.exc import SQLAlchemyError
from fastapi.responses import Response

from database import get_db, User as DBUser
from auth import get_current_user
from social_models import Follow, ClashRoom, ClashVote, Badge, InviteCode, HighlightClip, XPLog, PredictionVote

router = APIRouter(prefix="/api")

# Helper function

def _add_xp(db: Session, user: DBUser, points: int):
    user.xp_points += points
    db.add(XPLog(user_id=user.id, points=points))
    db.add(user)

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
async def clash_websocket_endpoint(websocket: WebSocket, clash_id: str,
                                   db: Session = Depends(get_db)):
    await websocket.accept()
    # Connection management
    connections = clash_ws_connections.setdefault(clash_id, [])
    connections.append(websocket)

    # Increment viewer count
    try:
        clash: ClashRoom | None = db.query(ClashRoom).filter(ClashRoom.id == clash_id).first()
        if clash:
            clash.viewer_count += 1
            db.add(clash)
            db.commit()
    except SQLAlchemyError:
        pass  # Non-critical

    try:
        while True:
            data = await websocket.receive_json()
            # Broadcast reaction to peers
            for conn in connections:
                if conn is not websocket:
                    await conn.send_json({"type": "reaction", "data": data})
    except WebSocketDisconnect:
        connections.remove(websocket)
        # Decrement viewer count
        try:
            clash = db.query(ClashRoom).filter(ClashRoom.id == clash_id).first()
            if clash and clash.viewer_count > 0:
                clash.viewer_count -= 1
                db.add(clash)
                db.commit()
        except SQLAlchemyError:
            pass

# ----------------------------
# FEED & LEADERBOARD
# ----------------------------

@router.get("/feed")
async def get_feed(current_user: DBUser = Depends(get_current_user), db: Session = Depends(get_db)):
    """Aggregated feed of live clashes from people you follow plus trending rooms."""
    # Get followees ids
    followees = db.query(Follow.followee_id).filter(Follow.follower_id == current_user.id).subquery()

    # Live clashes by followees
    followed_live = db.query(ClashRoom).filter(ClashRoom.status == "live", ClashRoom.streamer_a_id.in_(followees)).all()

    # Trending = top viewer count live rooms not in followed list
    trending_live = db.query(ClashRoom).filter(ClashRoom.status == "live").order_by(ClashRoom.viewer_count.desc()).limit(10).all()

    def serialize(room: ClashRoom):
        return {
            "clash_id": room.id,
            "streamerA": room.streamer_a_id,
            "streamerB": room.streamer_b_id,
            "viewerCount": room.viewer_count,
            "startedAt": room.created_at.isoformat()
        }

    feed_items = [serialize(r) for r in followed_live] + [serialize(r) for r in trending_live if r not in followed_live]
    return feed_items


@router.get("/leaderboard")
async def leaderboard(db: Session = Depends(get_db)):
    """Top 10 users by follower count."""
    from sqlalchemy import func

    results = (
        db.query(Follow.followee_id, func.count(Follow.follower_id).label("followers"))
        .group_by(Follow.followee_id)
        .order_by(func.count(Follow.follower_id).desc())
        .limit(10)
        .all()
    )
    return [
        {"userId": r.followee_id, "followers": r.followers}
        for r in results
    ]

# ----------------------------
# VOTING ENDPOINT
# ----------------------------

@router.post("/clashes/{clash_id}/vote")
async def vote_in_clash(clash_id: str, vote_for: str, current_user: DBUser = Depends(get_current_user), db: Session = Depends(get_db)):
    if vote_for not in ("A", "B"):
        raise HTTPException(status_code=400, detail="vote_for must be 'A' or 'B'")

    clash = db.query(ClashRoom).filter(ClashRoom.id == clash_id).first()
    if not clash:
        raise HTTPException(status_code=404, detail="Clash not found")

    # Upsert vote
    existing = db.query(ClashVote).filter(ClashVote.clash_id == clash_id, ClashVote.user_id == current_user.id).first()
    if existing:
        existing.vote_for = vote_for
    else:
        db.add(ClashVote(clash_id=clash_id, user_id=current_user.id, vote_for=vote_for))
        # award XP for first vote in a clash
        _add_xp(db, current_user, 5)
    db.commit()

    # Aggregate votes
    total_a = db.query(ClashVote).filter(ClashVote.clash_id == clash_id, ClashVote.vote_for == "A").count()
    total_b = db.query(ClashVote).filter(ClashVote.clash_id == clash_id, ClashVote.vote_for == "B").count()
    return {"A": total_a, "B": total_b}

# ----------------------------
# BADGES ENDPOINT
# ----------------------------

@router.get("/badges")
async def get_badges(current_user: DBUser = Depends(get_current_user), db: Session = Depends(get_db)):
    # Simple badge logic: 100 XP → "RisingStar", 500 XP → "SuperFan"
    earned_types = {b.badge_type for b in current_user.badges}

    new_badges = []
    if current_user.xp_points >= 100 and "RisingStar" not in earned_types:
        badge = Badge(user_id=current_user.id, badge_type="RisingStar")
        db.add(badge)
        new_badges.append("RisingStar")
    if current_user.xp_points >= 500 and "SuperFan" not in earned_types:
        badge = Badge(user_id=current_user.id, badge_type="SuperFan")
        db.add(badge)
        new_badges.append("SuperFan")

    if new_badges:
        db.commit()

    return {
        "xp": current_user.xp_points,
        "badges": [b.badge_type for b in current_user.badges] + new_badges
    }

# ----------------------------
# VIRAL INVITE LINKS
# ----------------------------

INVITE_CODE_LENGTH = 6

@router.post("/invite/generate")
async def generate_invite(background_tasks: BackgroundTasks, current_user: DBUser = Depends(get_current_user), db: Session = Depends(get_db)):
    code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=INVITE_CODE_LENGTH))
    db.add(InviteCode(code=code, inviter_id=current_user.id))
    db.commit()
    return {"code": code, "expiresInHours": 24}

@router.post("/invite/redeem")
async def redeem_invite(code: str, current_user: DBUser = Depends(get_current_user), db: Session = Depends(get_db)):
    invite = db.query(InviteCode).filter(InviteCode.code == code).first()
    if not invite:
        raise HTTPException(status_code=404, detail="Invalid code")
    if invite.used_by_id is not None:
        raise HTTPException(status_code=400, detail="Code already used")
    if datetime.utcnow() - invite.created_at > timedelta(hours=24):
        raise HTTPException(status_code=400, detail="Code expired")
    if current_user.id == invite.inviter_id:
        raise HTTPException(status_code=400, detail="Cannot redeem own code")

    invite.used_by_id = current_user.id
    # Award inviter XP
    inviter = db.query(DBUser).filter(DBUser.id == invite.inviter_id).first()
    if inviter:
        _add_xp(db, inviter, 50)
    # Award new user Legend badge
    legend_badge = Badge(user_id=current_user.id, badge_type="Legend")
    db.add(legend_badge)
    db.commit()
    return {"status": "success", "badge": "Legend"}

# ----------------------------
# DAILY DRAMA DROP
# ----------------------------
DRAMA_KEYWORDS = [
    "Minecraft mob vote",
    "MrBeast giveaway",
    "Fortnite season leak",
    "Taylor Swift album theory",
    "Roblox outage"
]

@router.get("/drama/today")
async def get_today_drama(current_user: DBUser = Depends(get_current_user)):
    seed = datetime.utcnow().strftime("%Y-%m-%d")
    random.seed(seed)
    keyword = random.choice(DRAMA_KEYWORDS)
    return {"keyword": keyword}

@router.post("/drama/start")
async def start_drama_clash(current_user: DBUser = Depends(get_current_user), db: Session = Depends(get_db)):
    today = datetime.utcnow().date()
    existing = db.query(ClashRoom).filter(
        ClashRoom.streamer_a_id == current_user.id,
        ClashRoom.created_at >= datetime(today.year, today.month, today.day)
    ).first()
    if existing:
        return {"clash_id": existing.id, "status": existing.status}

    seed = datetime.utcnow().strftime("%Y-%m-%d")
    random.seed(seed)
    keyword = random.choice(DRAMA_KEYWORDS)
    clash = ClashRoom(streamer_a_id=current_user.id, streamer_b_id="DramaBot", status="live")
    db.add(clash)
    db.commit()
    db.refresh(clash)
    return {"clash_id": clash.id, "keyword": keyword}

# ----------------------------
# CLIP ROULETTE
# ----------------------------
@router.get("/clips/roulette")
async def clip_roulette(limit: int = 10, db: Session = Depends(get_db)):
    clips = db.query(HighlightClip).order_by(func.random()).limit(limit).all()
    return [
        {"clip_id": c.id, "url": c.file_url, "caption": c.caption}
        for c in clips
    ]

# ----------------------------
# CLIP TO TIKTOK (stub)
# ----------------------------
@router.get("/clips/{clip_id}/tiktok")
async def clip_to_tiktok(clip_id: str, db: Session = Depends(get_db)):
    clip = db.query(HighlightClip).filter(HighlightClip.id == clip_id).first()
    if not clip:
        raise HTTPException(status_code=404, detail="Clip not found")
    # Stub: In real implementation, a background job would burn captions & merge trending sound.
    share_url = f"https://tiktok.com/upload?video={clip.file_url}"
    return {"uploadUrl": share_url}

# ----------------------------
# HIGHLIGHT GENERATION TRIGGER
# ----------------------------

from highlight_service import generate_highlights

@router.post("/clashes/{clash_id}/highlights/trigger")
async def trigger_highlight(clash_id: str, background_tasks: BackgroundTasks, current_user: DBUser = Depends(get_current_user)):
    background_tasks.add_task(generate_highlights, clash_id)
    return {"status": "queued"}

# ----------------------------
# OG IMAGE ENDPOINT
# ----------------------------

@router.get("/clashes/{clash_id}/share.png")
async def generate_share_image(clash_id: str, db: Session = Depends(get_db)):
    clash = db.query(ClashRoom).filter(ClashRoom.id == clash_id).first()
    if not clash:
        raise HTTPException(status_code=404, detail="Clash not found")

    # Simple image
    img = Image.new("RGB", (1200, 630), color=(30, 30, 30))
    draw = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("DejaVuSans-Bold.ttf", 72)
    except IOError:
        font = ImageFont.load_default()
    text = f"{clash.streamer_a_id}  VS  {clash.streamer_b_id}"
    w, h = draw.textsize(text, font=font)
    draw.text(((1200-w)/2, (630-h)/2), text, fill=(255, 255, 255), font=font)

    buf = io.BytesIO()
    img.save(buf, format="PNG")
    buf.seek(0)
    return Response(content=buf.getvalue(), media_type="image/png")

# ----------------------------
# PREDICTION VOTES
# ----------------------------
@router.post("/disputes/{dispute_id}/predict")
async def predict_outcome(dispute_id: str, guess: str, current_user: DBUser = Depends(get_current_user), db: Session = Depends(get_db)):
    if guess not in ("partyA", "partyB", "draw"):
        raise HTTPException(status_code=400, detail="Bad guess value")
    existing = db.query(PredictionVote).filter(PredictionVote.dispute_id==dispute_id, PredictionVote.user_id==current_user.id).first()
    if existing:
        existing.guess = guess
    else:
        db.add(PredictionVote(dispute_id=dispute_id, user_id=current_user.id, guess=guess))
    db.commit()
    return {"status":"ok"}

@router.post("/disputes/{dispute_id}/evaluate-predictions")
async def evaluate_predictions(dispute_id: str, winner: str, db: Session = Depends(get_db)):
    if winner not in ("partyA", "partyB", "draw"):
        raise HTTPException(status_code=400, detail="Bad winner")
    votes = db.query(PredictionVote).filter(PredictionVote.dispute_id==dispute_id, PredictionVote.processed==False).all()
    result = []
    for v in votes:
        user = db.query(DBUser).filter(DBUser.id==v.user_id).first()
        delta = 10 if v.guess == winner else -10
        _add_xp(db, user, delta)
        v.processed = True
        result.append({"user": v.user_id, "delta": delta})
    db.commit()
    return result

# ----------------------------
# LEADERBOARDS
# ----------------------------
from sqlalchemy import func, desc, Date

@router.get("/leaderboard/overall")
async def overall_leaderboard(limit: int = 20, db: Session = Depends(get_db)):
    users = db.query(DBUser).order_by(DBUser.xp_points.desc()).limit(limit).all()
    return [{"userId": u.id, "xp": u.xp_points} for u in users]

@router.get("/leaderboard/daily")
async def daily_leaderboard(limit: int = 20, db: Session = Depends(get_db)):
    today = datetime.utcnow().date()
    subq = db.query(XPLog.user_id, func.sum(XPLog.points).label("points")).filter(func.date(XPLog.created_at)==today).group_by(XPLog.user_id).subquery()
    rows = db.query(subq.c.user_id, subq.c.points).order_by(subq.c.points.desc()).limit(limit).all()
    return [{"userId": r.user_id, "xpToday": r.points} for r in rows]

# ----------------------------
# USER SEARCH
# ----------------------------
@router.get("/users/search")
async def search_users(q: str, limit: int = 20, db: Session = Depends(get_db)):
    pattern = f"%{q.lower()}%"
    results = db.query(DBUser).filter(func.lower(DBUser.display_name).like(pattern)).limit(limit).all()
    return [
        {"id": u.id, "displayName": u.display_name, "xp": u.xp_points}
        for u in results
    ]

# ----------------------------
# DRAMA FEED – most voted live clashes
# ----------------------------
@router.get("/clashes/drama")
async def drama_feed(limit: int = 20, db: Session = Depends(get_db)):
    sub = (db.query(ClashVote.clash_id, func.count().label("votes"))
              .group_by(ClashVote.clash_id)
              .subquery())

    rows = (db.query(ClashRoom, sub.c.votes)
              .join(sub, ClashRoom.id == sub.c.clash_id)
              .filter(ClashRoom.status == "live")
              .order_by(sub.c.votes.desc())
              .limit(limit)
              .all())
    return [
        {
            "clash_id": r.ClashRoom.id,
            "streamerA": r.ClashRoom.streamer_a_id,
            "streamerB": r.ClashRoom.streamer_b_id,
            "viewerCount": r.ClashRoom.viewer_count,
            "startedAt": r.ClashRoom.created_at.isoformat(),
            "votes": int(r.votes)
        } for r in rows]

# ----------------------------
# HOT TOPICS
# ----------------------------
@router.get("/hot-topics")
async def hot_topics(limit: int = 10):
    random.seed(datetime.utcnow().hour)
    topics = random.sample(DRAMA_KEYWORDS, k=min(limit, len(DRAMA_KEYWORDS)))
    return topics