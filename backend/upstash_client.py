import os
import json
import httpx
from typing import Any, Optional

UPSTASH_REDIS_REST_URL = os.getenv("UPSTASH_REDIS_REST_URL")
UPSTASH_REDIS_REST_TOKEN = os.getenv("UPSTASH_REDIS_REST_TOKEN")

def _headers() -> dict[str, str]:
    return {
        "Authorization": f"Bearer {UPSTASH_REDIS_REST_TOKEN}",
    }

def get(key: str) -> Optional[Any]:
    """Fetch a value from Upstash Redis (assumes JSON). Returns None if missing or on error."""
    if not (UPSTASH_REDIS_REST_URL and UPSTASH_REDIS_REST_TOKEN):
        return None

    url = f"{UPSTASH_REDIS_REST_URL}/get/{key}"
    try:
        resp = httpx.get(url, headers=_headers(), timeout=5)
        if resp.status_code == 200:
            data = resp.json().get("result")
            if data is None:
                return None
            try:
                return json.loads(data)
            except json.JSONDecodeError:
                return data
    except Exception:
        return None

    return None

def set(key: str, value: Any, ex: int | None = None) -> bool:
    """Set a JSON-serialisable value in Upstash Redis."""
    if not (UPSTASH_REDIS_REST_URL and UPSTASH_REDIS_REST_TOKEN):
        return False

    to_store = json.dumps(value)
    url = f"{UPSTASH_REDIS_REST_URL}/set/{key}/{to_store}"
    if ex:
        url += f"?ex={ex}"
    try:
        resp = httpx.post(url, headers=_headers(), timeout=5)
        return resp.status_code == 200
    except Exception:
        return False