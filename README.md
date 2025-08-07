# Formly - Plateforme Product Management IA (Architecture Hybride)

Ce monorepo contient l’implémentation initiale (scaffolding) d’une plateforme e-learning Product Management IA basée sur l’architecture validée :
- Frontend: Next.js 14 + React + TypeScript + Tailwind CSS
- Backend: FastAPI + Supabase (PostgreSQL)
- Services spécialisés: Streamlit (Chatbot + Dashboard)
- Orchestration: n8n (workflows)
- Déploiement: Railway (multi-services)

Démarrage rapide

1) Prérequis
- Node.js 18+
- Python 3.10+
- Supabase projet (URL + anon key)
- Railway CLI (optionnel pour déploiement)

2) Variables d’environnement (local)
- Créez un fichier .env à la racine (ou utilisez Railway Variables) avec:
  SUPABASE_URL=
  SUPABASE_ANON_KEY=
  OPENAI_API_KEY=
  RAGIE_API_KEY=
  STRIPE_SECRET_KEY=
  GOOGLE_MEET_CREDENTIALS=
  BACKEND_API_URL=http://localhost:8000

3) Installation et lancement
- Frontend
  cd frontend
  npm install
  npm run dev
  (http://localhost:3000)

- Backend
  cd backend
  python -m venv .venv && source .venv/bin/activate
  pip install -r requirements.txt
  uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
  (http://localhost:8000)

- Streamlit Chat
  cd streamlit-chat
  python -m venv .venv && source .venv/bin/activate
  pip install -r requirements.txt
  streamlit run app.py --server.port 8501

- Streamlit Dashboard
  cd streamlit-dashboard
  python -m venv .venv && source .venv/bin/activate
  pip install -r requirements.txt
  streamlit run app.py --server.port 8502

- n8n (exemple)
  Voir n8n/workflows/registration_onboarding.json et importer dans votre instance n8n.

4) Supabase (schema)
- Appliquez supabase/schema.sql à votre base (via Supabase SQL Editor).

Structure

- frontend/: Next.js app dir, pages publiques, onboarding, intégration Supabase
- backend/: FastAPI API (auth, formations, users, webinaires, ai_validation)
- streamlit-chat/: Chatbot Ragie + auth par token
- streamlit-dashboard/: Analytics de progression + recommandations
- n8n/workflows/: Workflows d’automatisation
- supabase/: Schéma SQL initial

Notes
- Ce scaffold fournit le minimum exécutable et des stubs/handlers pour évoluer rapidement.
- Les composants UI (shadcn/ui) peuvent être ajoutés via le CLI shadcn ensuite.
- Les secrets ne doivent pas être commités. Utilisez Railway Variables ou .env local.

Licence
- MIT

