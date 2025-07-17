# Data Retrieval & Hosting Guide

This guide shows you how to fetch **all application data** (users, disputes, truths, resolutions, etc.) and lists a few turn-key services where you can host the database, FastAPI backend, and object storage.

---

## 1  Retrieving All Data via the Admin API

### 1.1  Prerequisites

• The FastAPI server must be running (locally `uvicorn backend.mediation_api:app --reload` or on your cloud host).  
• You need **admin access** (❗ currently the `/api/admin/users` route is open; add authentication before production).

### 1.2  Example Request

```bash
# Local dev – default port 8000
echo "Fetching full dataset …"
curl -s http://localhost:8000/api/admin/users | jq > export.json
```

`export.json` will contain an array of every user with:

* `email`, `display_name`, timestamps
* `truths` – each truth statement they posted
* `disputes` – every dispute they created or joined, role, status, resolution text

### 1.3  Filtering & Pagination

The current endpoint returns **all** rows in one call. If the dataset becomes big:

1. Add query params `?offset=&limit=` in the route signature.
2. Use SQLAlchemy `.offset()` / `.limit()`.

<details>
<summary>Sample code</summary>

```python
@app.get("/api/admin/users")
async def admin_get_all_users(offset: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    users = db.query(DBUser).offset(offset).limit(limit).all()
    …
```
</details>

---

## 2  Database & Backend Hosting Options

| Layer | Recommended Service | Free Tier | Steps to Sign-Up |
|-------|---------------------|-----------|------------------|
| **PostgreSQL Database** | **Supabase** (supabase.com) | 500 MB | 1. Sign-up with GitHub/Google  <br>2. Create new **Project** → choose region  <br>3. Copy `DB_URL` & `JWT_SECRET` into `DATABASE_URL` env var |
| | **Render** (render.com) | 90 days | 1. Create account → **Databases**  <br>2. New PostgreSQL → region, size  <br>3. Note internal/external URLs |
| **Backend (FastAPI)** | **Railway** (railway.app) | 0.5 GB RAM, 1 GB storage | 1. `railway init` & `railway up` or GitHub import  <br>2. Add `DATABASE_URL` in **Variables**  <br>3. Deploy |
| | **Fly.io** (fly.io) | 3 shared-CPU VM | 1. `flyctl launch` inside project  <br>2. `fly secrets set DATABASE_URL=…`  <br>3. `fly deploy` |
| **Object/File Storage** | **AWS S3** | 5 GB | 1. AWS account → S3 → Create bucket  <br>2. Generate IAM key with minimal access  <br>3. Store creds (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) as env vars |
| | **Cloudflare R2** | 10 GB | Same as S3 API |

> 📝 **ENV Setup** – set `DATABASE_URL`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `S3_BUCKET_NAME` in your hosting dashboard; the backend reads them with `os.getenv(...)`.

---

## 3  Local Development Cheatsheet

```bash
# 1. Create & seed local DB
python -m backend.database  # creates SQLite file mediationai.db

# 2. Start the API (auto-reload)
uvicorn backend.mediation_api:app --reload

# 3. Hit the health check
curl http://127.0.0.1:8000/api/health | jq
```

---

## 4  Next Steps

1. **Protect admin endpoints** – add JWT role check or IP allow-list.  
2. **Daily backup** – schedule `pg_dump` on your host or enable managed backups.  
3. **Monitoring** – enable Supabase logs or add Prometheus/Grafana on Fly / Render.

Happy building! ✨