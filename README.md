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
- Python 3.11+
- Supabase projet (URL + anon key)
- Railway CLI (optionnel pour déploiement)

Prérequis macOS (recommandés)
- Homebrew (gestionnaire de paquets)
- Node et npm
- Python 3.11

Commandes d’installation suggérées (macOS)
- Installer Homebrew: voir https://brew.sh
- Installer Node (inclut npm):
  brew install node
- Installer Python 3.11:
  brew install python@3.11

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
- Vérifier les prérequis (macOS):
  make check

- Frontend
  cd frontend
  npm install
  npm run dev
  (http://localhost:3000)

- Backend
  cd backend
  python3.11 -m venv .venv311 && source .venv311/bin/activate
  pip install -r requirements.txt
  uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
  (http://localhost:8000)

- Streamlit Chat
  cd streamlit-chat
  python3.11 -m venv .venv311 && source .venv311/bin/activate
  pip install -r requirements.txt
  streamlit run app.py --server.port 8501

- Streamlit Dashboard
  cd streamlit-dashboard
  python3.11 -m venv .venv311 && source .venv311/bin/activate
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

---

Développeurs — Guide rapide (Makefile)

Aperçu du workflow
- make check: vérifie les prérequis macOS
- make env:frontend: génère le squelette .env.local pour le frontend
- make install: installe les dépendances (frontend npm, venv Python + pip)
- make start | stop | restart: gère tous les services (frontend, backend, streamlit-chat, streamlit-dashboard)
- make status: affiche l’état (RUNNING/NOT RUNNING) et les ports
- make logs: affiche les 200 dernières lignes de chaque service
- make logs.watch SERVICE={frontend|backend|streamlit-chat|streamlit-dashboard}: suit en direct les logs d’un service
- Répertoires: logs/ pour les journaux, pids/ pour les fichiers PID

Prérequis et installation (macOS)
- Homebrew
- Node.js 18+
- Python 3.11+
- Outils système: lsof, ps, kill, tail (fourni par défaut sur macOS)

Installation via Homebrew (recommandé)
- Installer Homebrew: https://brew.sh
- Installer Node (inclut npm):
  brew install node
- Installer Python 3.11:
  brew install python@3.11
- Optionnel: vérifier la configuration
  make check

Première mise en place
- Générer l’environnement frontend:
  make env:frontend
- Installer toutes les dépendances:
  make install

Utilisation quotidienne
- Démarrer tous les services:
  make start
- Vérifier l’état:
  make status
- Voir les logs (dernières 200 lignes):
  make logs
- Suivre les logs d’un service en continu, exemple backend:
  make logs.watch SERVICE=backend
- Arrêter tous les services:
  make stop
- Redémarrer tous les services:
  make restart

Ports et URLs de services (local)
- Frontend:           http://localhost:3000
- Backend (si dispo): http://localhost:8000
- Streamlit Chat:     http://localhost:8501
- Streamlit Dashboard:http://localhost:8502

Dépannage
- Nettoyer des fichiers PID obsolètes (stale PID):
  - La commande make stop tente déjà de nettoyer les PID périmés
  - Si besoin, suppression manuelle:
    rm -f pids/*.pid
- Libérer un port déjà utilisé (exemples):
  - Trouver et tuer le processus sur le port 3000:
    lsof -iTCP:3000 -sTCP:LISTEN -t | xargs kill -9
  - Idem pour d’autres ports (8000, 8501, 8502)
- Où trouver les logs:
  - Fichiers: logs/frontend.log, logs/backend.log, logs/streamlit-chat.log, logs/streamlit-dashboard.log
  - Commandes: make logs ou make logs.watch SERVICE=frontend
