# Using Upstash Redis in MediationAI

> The goal: store lightweight JSON snapshots (users, disputes, chat transcripts, …) in a serverless key-value store that works on Vercel **and** can be exported later to fine-tune or retrain large-language models.

---

## 1. Why Upstash?
* **HTTP native** – every runtime (Vercel, edge-functions, Cron jobs) can hit it without a TCP Redis driver.
* **Free tier** – perfect for early-stage projects.
* **Scales** – you can flip a switch for higher limits later.
* **Low-latency** – region-aware edge caches.

---

## 2. One-time setup
1. Create a database at <https://upstash.com> → *Redis*.
2. In the *REST API* tab copy:
   * **REST URL** `https://your-db-id.upstash.io`
   * **REST TOKEN** `AXXX…`
3. Vercel → Settings → Environment Variables

```
UPSTASH_REDIS_REST_URL    https://your-db-id.upstash.io
UPSTASH_REDIS_REST_TOKEN  AXXX…
```

Redeploy – the backend now has access.

---

## 3. Code overview

```python
# backend/upstash_client.py
from upstash_client import get, set

set("users", [{"id": "1", "email": "alice@example.com"}])
users = get("users")  # → list[dict]
```

The helper simply hits Upstash’s REST endpoints:

```
GET  $URL/get/<key>
POST $URL/set/<key>/<json_encoded_value>
```

You can add TTL with the `ex` parameter:

```python
set("session:abc", {"user_id": 1}, ex=3600)  # expires in 1 h
```

---

## 4. Recommended key structure
| Prefix            | Purpose                           | Example                        |
|-------------------|-----------------------------------|--------------------------------|
| `users`           | All registered users              | `users` → JSON array           |
| `user:<id>`       | Single user snapshot              | `user:42` → JSON object        |
| `dispute:<id>`    | Dispute object incl. evidence     | `dispute:abc` → JSON object    |
| `chat:<dispute>`  | List of chat messages             | `chat:abc` → JSON array        |

*Flat keys keep REST calls simple and make bulk-export trivial.*

---

## 5. Exporting data for LLM training

Below is a quick script that pulls every key with a prefix, converts to JSONL (one-JSON-object-per-line) – the format most fine-tuning pipelines expect.

```python
# scripts/export_upstash_to_jsonl.py
import os, httpx, json, sys
BASE = os.environ["UPSTASH_REDIS_REST_URL"]
HDRS = {"Authorization": f"Bearer {os.environ['UPSTASH_REDIS_REST_TOKEN']}"}
PREFIX = sys.argv[1]  # e.g. "chat:"

# 1. list keys (Upstash supports SCAN via REST)
keys = httpx.get(f"{BASE}/scan/0?match={PREFIX}*", headers=HDRS).json()["result"][1]

with open(f"{PREFIX.rstrip(':')}.jsonl", "w") as f:
    for k in keys:
        data = httpx.get(f"{BASE}/get/{k}", headers=HDRS).json()["result"]
        # ensure each line is valid JSON (string already JSON-encoded)
        f.write(data + "\n")
print("Exported", len(keys), "records →", f.name)
```

You can now feed `chat.jsonl` or `dispute.jsonl` straight into OpenAI’s `fine_tunes` API or a local embedding workflow.

---

## 6. Tips for training-grade data
*  **De-identify** – replace emails / names with hashes before export.
*  **Chunk long texts** – if a single dispute chat is huge, store an array of message objects; chunk during export.
*  **Metadata** – include fields like `role`, `timestamp`, `resolution` to enable better supervised training.
*  **Versioning** – store snapshots under keys like `dispute:abc:v1` so you can iterate without overwriting.

---

## 7. Next steps
* Add write-paths (after each user action) to push latest state into Upstash.
* Schedule a Vercel Cron to dump daily JSONL backups to S3/GCS.
* When moving to billions of tokens, switch to Upstash *vector* indexes or pipe the JSONL into Pinecone / Postgres-ML.

With this setup you have: serverless storage, a production-safe API route, and a zero-friction path to pull the same data into any LLM training pipeline.