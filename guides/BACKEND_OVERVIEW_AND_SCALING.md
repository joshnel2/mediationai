# Backend Architecture, Data Flow & Scaling Roadmap

> Last updated: $(date)

---

## 1. High-level Architecture

```text
┌─────────────┐      HTTP / WS      ┌───────────────┐
│  iOS App    │  ───────────────→  │   FastAPI     │
│  (SwiftUI)  │                    │  backend      │
└─────────────┘                    │  (ASGI)       │
         ▲                         └───────────────┘
         │  JSON (REST) / WebSocket      │        ▲
         │                               │        │
         │                               ▼        │
         │                      ┌──────────────────┐
         │                      │  SQLAlchemy ORM  │
         │                      └────────┬─────────┘
         │                               │ (CRUD)
         │                               ▼
         │                      ┌──────────────────┐
         │                      │ PostgreSQL /     │
         │                      │ SQLite (dev)     │
         │                      └──────────────────┘
         │                               ▲
         │                               │
         │    File uploads (S3/R2)        │
         │                               │
         ▼                               ▼
┌──────────────────┐             ┌──────────────────┐
│ Object Storage   │             │ OpenAI / Anthropic│
│  (images/docs)   │             │  (AI models)      │
└──────────────────┘             └──────────────────┘
```

* **FastAPI** handles REST + WebSocket endpoints.
* **SQLAlchemy** maps Python models to a relational DB.
* **Mediation agents** (in `backend/mediation_agents.py`) talk to LLM APIs to draft resolutions & contracts.
* **Background tasks** (FastAPI + `BackgroundTasks`) generate contracts and run long AI jobs without blocking HTTP threads.

---

## 2. Request/Response Flow

| Step | Endpoint | What Happens | Key Tables |
|------|----------|--------------|------------|
| 1 | `POST /api/register` | Hashes password, inserts row in `users` | users |
| 2 | `POST /api/disputes` | Creates dispute, status = `invite_sent` | disputes |
| 3 | `POST /api/disputes/{id}/join` | 2nd party added (`dispute_participants`) | dispute_participants |
| 4 | `POST /evidence` | Multipart upload → S3 (future) & DB row | evidence |
| 5 | `POST /messages` | Inserts chat; AI mediator may reply | messages |
| 6 | `POST /resolve` | Orchestrator picks mediator/arbitrator → resolution JSON | disputes / resolutions |
| 7 | `POST /contract/generate`* | Background task builds legal text | disputes (`contract_text`) |
| 8 | `POST /contract/sign` (x2) | Signatures appended; once all signed ⇒ `fully_executed=true` | contract_signatures |

\*Triggered only if `requires_contract=true`.

---

## 3. Data Model Cheatsheet

| Table | Purpose | Important Fields |
|-------|---------|------------------|
| users | Accounts | `email`, `password_hash`, flags |
| disputes | Core case | `title`, `status`, `requires_contract`, `contract_text` |
| truths | Long-form statements | FK `dispute_id`, `user_id`, `content` |
| evidence | File or text blobs | `file_type`, `file_size`, `uploaded_at` |
| messages | Chat / AI / system | `sender_type`, `is_private`, `recipient_id` |
| ... | see `backend/database.py` | |

The iOS app mirrors these via Codable structs in `frontend/user.swift` and friends.

---

## 4. Privacy Logic

* Chat endpoint `/messages` supports `is_private=true` & `recipient_id`.
* Retrieval `/messages?for_user_id=…` (added in the last commit) filters so a user sees:
  * **Public** messages, plus
  * Private messages where they are **sender** or **recipient**.

This prevents cross-party snooping; only the final resolution / contract is shared globally.

---

## 5. Deployment & Env Vars

| Var | Description |
|-----|-------------|
| `DATABASE_URL` | Postgres connection string or `sqlite:///…` for dev |
| `OPENAI_API_KEY` / `ANTHROPIC_API_KEY` | Enables AI generation |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | Required once S3 storage is enabled |
| `S3_BUCKET_NAME` | Bucket for evidence files |
| `SECRET_KEY` | JWT token signing (see `auth.py`) |

Recommend using a secrets manager (AWS Secrets Manager, Doppler, 1Password) in production.

---

## 6. Future Road-Map & Scaling Plan

### 6.1 Stability / Performance

1. **Async worker pool** – move background tasks to Celery + Redis or a Queue (SQS, RabbitMQ) for predictable throughput.
2. **Database migrations** – integrate Alembic for schema changes; run migrations on deploy.
3. **Read replicas** – once read-heavy (messages) exceeds 1k req/s, split reads.
4. **Connection pooling** – use `uvicorn --workers N` + `SQLAlchemy` pool.
5. **CDN for assets** – offload image/attachment traffic to CloudFront/Cloudflare.

### 6.2 Security

1. **RBAC / JWT scopes** – add `role` (user, admin) claims; protect `/admin/*` routes.
2. **OAuth / Social Login** – reduce password handling surface.
3. **File virus-scanning** – Lambda / Cloudflare AV scan before evidence is accepted.
4. **Rate limiting** – `slowapi` / API-gateway limits per IP & user.
5. **Audit logs** – immutable trail for dispute edits & contract signatures.
6. **GDPR / Data-deletion** – scheduled scrub jobs + right-to-be-forgotten endpoint.

### 6.3 Efficiency / Cost

1. **LLM caching** – Redis cache key on `prompt+model` to avoid duplicate costs.
2. **Scheduled clean-ups** – lifecycle rules on S3 bucket & database archival.
3. **Streaming AI responses** – use Server-Sent-Events to reduce idle wait.
4. **Autoscaling** – container deploy on Fly.io with `min=2 max=10` machines.

### 6.4 Feature Backlog

* Multi-party (>2) disputes.
* Third-party expert review marketplace.
* In-app payments (Stripe Connect) for escrow.
* Push-notification service (Firebase APNs) for iOS real-time updates.
* Zero-downtime blue-green deploys.
* Internationalization (locale-aware contracts).

---

## 7. Local Dev Tips

```bash
# create DB & tables
python -m backend.database  

# run tests (coming soon)
pytest -q

# run server with auto-reload
uvicorn backend.mediation_api:app --reload
```

---

## 8. Contact & Contribution

Open issues / PRs on GitHub or ping @maintainers in Slack.

Happy hacking! 🚀