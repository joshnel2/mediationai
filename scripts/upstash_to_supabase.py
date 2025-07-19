import os, httpx, json, time

BASE = os.environ["UPSTASH_REDIS_REST_URL"]
UH   = {"Authorization": f"Bearer {os.environ['UPSTASH_REDIS_REST_TOKEN']}"}
SURL = os.environ["SUPABASE_URL"]
SKEY = os.environ["SUPABASE_SERVICE_KEY"]
SH   = {
    "apikey": SKEY,
    "Authorization": f"Bearer {SKEY}",
    "Content-Type": "application/json",
    "Prefer": "resolution=merge-duplicates"
}

def scan(prefix: str):
    return httpx.get(f"{BASE}/scan/0?match={prefix}*", headers=UH).json()["result"][1]

def get(key: str):
    raw = httpx.get(f"{BASE}/get/{key}", headers=UH).json()["result"]
    return json.loads(raw) if raw else None

def upsert(table: str, row: dict):
    httpx.post(f"{SURL}/rest/v1/{table}", headers=SH, json=row, timeout=10)


def sync_users():
    for u in (get("users") or []):
        upsert("users", {**u, "payload": u})


def sync_disputes_and_messages():
    for key in scan("dispute:"):
        d   = get(key)
        if not d:  # Key may have been deleted
            continue
        did = d["id"]
        upsert("disputes", {
            "id": did,
            "title": d.get("title"),
            "status": d.get("status"),
            "resolution": d.get("final_resolution"),
            "snapshot": d,
            "updated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ")
        })
        for m in (get(f"chat:{did}") or []):
            upsert("messages", {
                "id": m["id"],
                "dispute_id": did,
                "sender_id": m["sender_id"],
                "role": m["sender_type"],
                "content": m["content"],
                "timestamp": m.get("timestamp"),
                "payload": m
            })


def handler(event=None, context=None):  # allows Vercel cron (python entrypoint)
    sync_users()
    sync_disputes_and_messages()
    return {"status": "ok"}

if __name__ == "__main__":
    handler()
    print("Upstash ➜ Supabase sync complete")