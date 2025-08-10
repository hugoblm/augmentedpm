# =====================
# Status and Logs
# =====================
SHELL := bash
PY311 := python3.11

.PHONY: status logs logs.watch
status:
	@echo "[STATUS] Checking services..."
	@for svc in "$(FRONTEND_NAME)" "$(BACKEND_NAME)" "$(CHAT_NAME)" "$(DASH_NAME)"; do \
		case "$$svc" in \
			"$(FRONTEND_NAME)") PID_FILE="$(FRONTEND_PID)"; PORT="$(FRONTEND_PORT)";; \
			"$(BACKEND_NAME)") PID_FILE="$(BACKEND_PID)"; PORT="$(BACKEND_PORT)";; \
			"$(CHAT_NAME)") PID_FILE="$(CHAT_PID)"; PORT="$(CHAT_PORT)";; \
			"$(DASH_NAME)") PID_FILE="$(DASH_PID)"; PORT="$(DASH_PORT)";; \
		esac; \
		if [ -f "$$PID_FILE" ]; then \
			PID=$$(cat "$$PID_FILE" 2>/dev/null || true); \
			if [ -n "$$PID" ] && kill -0 $$PID >/dev/null 2>&1; then \
				echo "- $$svc: RUNNING (pid=$$PID, port=$$PORT)"; \
			else \
				echo "- $$svc: NOT RUNNING (stale pid file; run 'make stop' to clean)"; \
			fi; \
		else \
			echo "- $$svc: NOT RUNNING"; \
		fi; \
	done

logs:
	@echo "[LOGS] Last 200 lines per service (if any)"
	@for svc in "$(FRONTEND_NAME)" "$(BACKEND_NAME)" "$(CHAT_NAME)" "$(DASH_NAME)"; do \
		case "$$svc" in \
			"$(FRONTEND_NAME)") LOG_FILE="$(FRONTEND_LOG)";; \
			"$(BACKEND_NAME)") LOG_FILE="$(BACKEND_LOG)";; \
			"$(CHAT_NAME)") LOG_FILE="$(CHAT_LOG)";; \
			"$(DASH_NAME)") LOG_FILE="$(DASH_LOG)";; \
		esac; \
		if [ -f "$$LOG_FILE" ]; then \
			echo "===== $$svc (tail -n 200) ====="; \
			TAIL_LINES=$$(tail -n 200 "$$LOG_FILE" 2>/dev/null); \
			if [ -n "$$TAIL_LINES" ]; then printf "%s\n" "$$TAIL_LINES"; else echo "(log file exists but empty)"; fi; \
		else \
			echo "===== $$svc ====="; echo "(no log yet)"; \
		fi; \
		echo; \
	done

.PHONY: logs.frontend logs.backend logs.chat logs.dashboard
logs.frontend:
	@if [ -f "$(FRONTEND_LOG)" ]; then tail -n 200 "$(FRONTEND_LOG)"; else echo "[INFO] No frontend log at $(FRONTEND_LOG)"; fi

logs.backend:
	@if [ -f "$(BACKEND_LOG)" ]; then tail -n 200 "$(BACKEND_LOG)"; else echo "[INFO] No backend log at $(BACKEND_LOG)"; fi

logs.chat:
	@if [ -f "$(CHAT_LOG)" ]; then tail -n 200 "$(CHAT_LOG)"; else echo "[INFO] No chat log at $(CHAT_LOG)"; fi

logs.dashboard:
	@if [ -f "$(DASH_LOG)" ]; then tail -n 200 "$(DASH_LOG)"; else echo "[INFO] No dashboard log at $(DASH_LOG)"; fi

# Usage: make logs.watch SERVICE=backend
logs.watch:
	@if [ -z "$(SERVICE)" ]; then \
		echo "Usage: make logs.watch SERVICE={frontend|backend|streamlit-chat|streamlit-dashboard}"; \
		exit 1; \
	fi; \
	case "$(SERVICE)" in \
		frontend) LOG_FILE="$(FRONTEND_LOG)";; \
		backend) LOG_FILE="$(BACKEND_LOG)";; \
		streamlit-chat) LOG_FILE="$(CHAT_LOG)";; \
		streamlit-dashboard) LOG_FILE="$(DASH_LOG)";; \
		*) echo "Unknown service: $(SERVICE)"; exit 1;; \
	esac; \
	if [ ! -f "$$LOG_FILE" ]; then \
		echo "[INFO] No log yet at $$LOG_FILE. Will follow when created..."; \
		touch "$$LOG_FILE"; \
	fi; \
	tail -f "$$LOG_FILE"

# Service management Makefile

# Directories for logs and PIDs
LOG_DIR := logs
PID_DIR := pids

# Ensure required directories exist
.PHONY: init-dirs
init-dirs:
	@mkdir -p $(LOG_DIR) $(PID_DIR)

# Utility to check if a command exists
# Usage: $(call has_cmd,cmd)
has_cmd = command -v $(1) > /dev/null 2>&1

# Helper snippets
# Usage: $(call is_pid_alive,1234)
#        $(call wait_graceful,1234,10)  # wait up to 10s for pid to exit
#        $(call port_in_use,3000)
# These are inline shell snippets intended to be used inside recipe command contexts.
is_pid_alive = kill -0 $(1) >/dev/null 2>&1
wait_graceful = i=0; while [ $$i -lt $(2) ]; do if ! kill -0 $(1) >/dev/null 2>&1; then break; fi; sleep 1; i=$$((i+1)); done
port_in_use = lsof -iTCP:$(1) -sTCP:LISTEN -t >/dev/null 2>&1

# =====================
# Preflight checks (macOS)
# =====================
.PHONY: check
check:
	@echo "[CHECK] Running preflight checks for macOS prerequisites..."
	@MISSING=0; \
	if ! $(call has_cmd,brew); then \
		echo "[MISSING] Homebrew (brew) is not installed."; \
		echo "          Install Homebrew from https://brew.sh and then run: brew install node python@3.11"; \
		MISSING=1; \
	else \
		echo "[OK] brew found: $$(brew --version | head -n1)"; \
	fi; \
	if ! $(call has_cmd,node); then \
		echo "[MISSING] node not found on PATH."; \
		echo "          Suggestion (macOS): brew install node"; \
		MISSING=1; \
	else \
		echo "[OK] node found: $$(node --version 2>/dev/null)"; \
	fi; \
	if ! $(call has_cmd,npm); then \
		echo "[MISSING] npm not found on PATH."; \
		echo "          Suggestion (macOS): brew install node (includes npm)"; \
		MISSING=1; \
	else \
		echo "[OK] npm found: $$(npm --version 2>/dev/null)"; \
	fi; \
	if ! $(call has_cmd,python3.11); then \
		echo "[MISSING] python3.11 not found on PATH."; \
		echo "          Suggestion (macOS): brew install python@3.11"; \
		echo "          After install, you may need to run: echo 'export PATH="/opt/homebrew/opt/python@3.11/bin:$$PATH"' >> ~/.zshrc"; \
		MISSING=1; \
	else \
		echo "[OK] python3.11 found: $$(python3.11 --version 2>/dev/null)"; \
	fi; \
	# streamlit checks inside project virtualenvs if present
	CHAT_VENV_PATH="$(CHAT_VENV)"; \
	DASH_VENV_PATH="$(DASH_VENV)"; \
	CHAT_STREAMLIT_PATH="$(CHAT_STREAMLIT)"; \
	DASH_STREAMLIT_PATH="$(DASH_STREAMLIT)"; \
	if [ -d "$$CHAT_VENV_PATH" ]; then \
		if [ -x "$$CHAT_STREAMLIT_PATH" ]; then \
			echo "[OK] streamlit (chat) found in venv: $$CHAT_STREAMLIT_PATH"; \
		else \
			echo "[MISSING] streamlit not found in chat venv at $$CHAT_STREAMLIT_PATH"; \
			echo "          Create venv and install: cd streamlit-chat && python3.11 -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt"; \
			MISSING=1; \
		fi; \
	else \
		echo "[INFO] streamlit-chat venv not found at $$CHAT_VENV_PATH (will skip deep check)."; \
		echo "       To set up: cd streamlit-chat && python3.11 -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt"; \
	fi; \
	if [ -d "$$DASH_VENV_PATH" ]; then \
		if [ -x "$$DASH_STREAMLIT_PATH" ]; then \
			echo "[OK] streamlit (dashboard) found in venv: $$DASH_STREAMLIT_PATH"; \
		else \
			echo "[MISSING] streamlit not found in dashboard venv at $$DASH_STREAMLIT_PATH"; \
			echo "          Create venv and install: cd streamlit-dashboard && python3.11 -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt"; \
			MISSING=1; \
		fi; \
	else \
		echo "[INFO] streamlit-dashboard venv not found at $$DASH_VENV_PATH (will skip deep check)."; \
		echo "       To set up: cd streamlit-dashboard && python3.11 -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt"; \
	fi; \
	for cmd in lsof ps kill tail; do \
		if ! $(call has_cmd,$$cmd); then \
			echo "[MISSING] $$cmd not found on PATH."; \
			echo "          On macOS these are typically available by default. If missing, ensure command line tools are installed: xcode-select --install"; \
			MISSING=1; \
		else \
			echo "[OK] $$cmd found."; \
		fi; \
	done; \
	if [ "$${MISSING}" = "0" ]; then \
		echo "[SUCCESS] All prerequisites look good!"; \
		exit 0; \
	else \
		echo "[ACTION REQUIRED] Some prerequisites are missing. See messages above for guidance."; \
		exit 1; \
	fi

# =====================
# Python venv setup for Python services
# =====================
.PHONY: setup-python
setup-python:
	@echo "[SETUP] Ensuring Python 3.11 virtualenvs and dependencies for backend, streamlit-chat, streamlit-dashboard"
	@for svc in backend streamlit-chat streamlit-dashboard; do \
		if [ ! -d "$$svc" ]; then \
			echo "[SKIP] $$svc: folder '$$svc' not found."; \
			continue; \
		fi; \
		VENV="$$svc/.venv"; \
		PY_BIN="$$VENV/bin/python"; \
		PIP_BIN="$$VENV/bin/pip"; \
		REQ="$$svc/requirements.txt"; \
		if [ ! -d "$$VENV" ]; then \
			echo "[INFO] $$svc: creating Python 3.11 venv at $$VENV"; \
			python3.11 -m venv "$$VENV"; \
		else \
			echo "[OK] $$svc: venv exists at $$VENV"; \
		fi; \
		if [ ! -f "$$REQ" ]; then \
			echo "[SKIP] $$svc: requirements.txt not found. Skipping pip install."; \
			continue; \
		fi; \
		if [ ! -x "$$PIP_BIN" ]; then \
			echo "[WARN] $$svc: pip not found at $$PIP_BIN (venv may be incomplete)."; \
		fi; \
		echo "[INSTALL] $$svc: installing dependencies from $$REQ"; \
		"$$PIP_BIN" install -r "$$REQ"; \
	done

# =====================
# Install: dependencies for frontend and Python services
# =====================
.PHONY: install
install: init-dirs
	@echo "[INSTALL] Starting install workflow..."
	@echo "[INSTALL] Checking frontend dependencies..."
	@if [ -d "$(FRONTEND_PATH)" ] && [ -f "$(FRONTEND_PATH)/package.json" ]; then \
		if ! $(call has_cmd,npm); then \
			echo "[SKIP] $(FRONTEND_NAME): 'npm' not available on PATH."; \
		else \
			if [ -f "$(FRONTEND_PATH)/package-lock.json" ]; then \
				echo "[INSTALL] $(FRONTEND_NAME): running 'npm ci' (lockfile present)"; \
				sh -c 'cd $(FRONTEND_PATH) && npm ci'; \
			else \
				echo "[INSTALL] $(FRONTEND_NAME): running 'npm install' (no lockfile found)"; \
				sh -c 'cd $(FRONTEND_PATH) && npm install'; \
			fi; \
		fi; \
	else \
		echo "[SKIP] $(FRONTEND_NAME): folder or package.json not found at $(FRONTEND_PATH)."; \
	fi
	@echo "[INSTALL] Ensuring Python environments and dependencies..."
	@$(MAKE) --no-print-directory setup-python

# =====================
# Service: frontend
# =====================
FRONTEND_NAME := frontend
FRONTEND_DIR := frontend
FRONTEND_PATH := $(FRONTEND_DIR)
FRONTEND_PORT := 3000
FRONTEND_ENV_FILE := .env.local
FRONTEND_LOG := $(LOG_DIR)/$(FRONTEND_NAME).log
FRONTEND_PID := $(PID_DIR)/$(FRONTEND_NAME).pid

.PHONY: start-frontend
start-frontend: init-dirs
	@if [ ! -d "$(FRONTEND_PATH)" ]; then \
		echo "[SKIP] $(FRONTEND_NAME): folder '$(FRONTEND_PATH)' not found."; \
		exit 0; \
	fi
	@if [ ! -f "$(FRONTEND_PATH)/package.json" ]; then \
		echo "[SKIP] $(FRONTEND_NAME): missing package.json in $(FRONTEND_PATH)."; \
		exit 0; \
	fi
	@if ! $(call has_cmd,npm); then \
		echo "[SKIP] $(FRONTEND_NAME): 'npm' not available on PATH."; \
		exit 0; \
	fi
	@if $(call port_in_use,$(FRONTEND_PORT)); then \
		echo "[ERROR] Port $(FRONTEND_PORT) is already in use. Please stop the conflicting process before starting $(FRONTEND_NAME)."; \
		lsof -iTCP:$(FRONTEND_PORT) -sTCP:LISTEN || true; \
		exit 1; \
	fi
	@if [ -f "$(FRONTEND_PID)" ]; then \
		PID=$$(cat "$(FRONTEND_PID)"); \
		if kill -0 $$PID > /dev/null 2>&1; then \
			echo "[RUNNING] $(FRONTEND_NAME) already running with PID $$PID"; \
			exit 0; \
		else \
			echo "[CLEANUP] $(FRONTEND_NAME) removing stale PID $$PID"; \
			rm -f "$(FRONTEND_PID)"; \
		fi; \
	fi
	@echo "[START] $(FRONTEND_NAME) on port $(FRONTEND_PORT). Logs: $(FRONTEND_LOG) PID: $(FRONTEND_PID)"
	@sh -c 'cd $(FRONTEND_PATH) && mkdir -p ../$(LOG_DIR) ../$(PID_DIR) && nohup env PORT=$(FRONTEND_PORT) npm run dev >> ../$(FRONTEND_LOG) 2>&1 & echo $$! > ../$(FRONTEND_PID)'
	@PID=$$(cat "$(FRONTEND_PID)" 2>/dev/null || true); \
	if [ -n "$$PID" ] && kill -0 $$PID > /dev/null 2>&1; then \
		echo "[OK] $(FRONTEND_NAME) started with PID $$PID"; \
	else \
		echo "[FAIL] $(FRONTEND_NAME) failed to start. First log lines:"; \
		head -n 50 "$(FRONTEND_LOG)" 2>/dev/null || echo "(no log yet)"; \
		exit 1; \
	fi

# =====================
# Env skeletons
# =====================
.PHONY: env-frontend
env-frontend:
	@if [ ! -d "$(FRONTEND_PATH)" ]; then \
		echo "[SKIP] $(FRONTEND_NAME): folder '$(FRONTEND_PATH)' not found."; \
		exit 0; \
	fi
	@ENV_FILE="$(FRONTEND_PATH)/$(FRONTEND_ENV_FILE)"; \
	if [ -f "$$ENV_FILE" ]; then \
		echo "[OK] $(FRONTEND_NAME): $$ENV_FILE already exists."; \
		exit 0; \
	else \
		echo "NEXT_PUBLIC_SUPABASE_URL=" > "$$ENV_FILE"; \
		echo "NEXT_PUBLIC_SUPABASE_ANON_KEY=" >> "$$ENV_FILE"; \
		echo "NEXT_PUBLIC_API_BASE_URL=http://localhost:8000" >> "$$ENV_FILE"; \
		echo "NEXT_PUBLIC_CHAT_URL=http://localhost:8501" >> "$$ENV_FILE"; \
		echo "NEXT_PUBLIC_DASHBOARD_URL=http://localhost:8502" >> "$$ENV_FILE"; \
		echo "[INFO] Created $$ENV_FILE. Remember to fill in the required values."; \
	fi

# Alias to satisfy env:frontend target name
env\:frontend: env-frontend

# =====================
# Service: backend
# =====================
BACKEND_NAME := backend
BACKEND_DIR := backend
BACKEND_PATH := $(BACKEND_DIR)
BACKEND_PORT := 8000
BACKEND_VENV := $(BACKEND_PATH)/.venv
BACKEND_PY := $(BACKEND_VENV)/bin/python
BACKEND_UVICORN := $(BACKEND_VENV)/bin/uvicorn
BACKEND_LOG := $(LOG_DIR)/$(BACKEND_NAME).log
BACKEND_PID := $(PID_DIR)/$(BACKEND_NAME).pid

.PHONY: start-backend
start-backend: init-dirs
	@if [ ! -d "$(BACKEND_PATH)" ]; then \
		echo "[SKIP] $(BACKEND_NAME): folder '$(BACKEND_PATH)' not found."; \
		exit 0; \
	fi
	@if [ ! -d "$(BACKEND_VENV)" ]; then \
		echo "[SKIP] $(BACKEND_NAME): Python 3.11 venv not found at '$(BACKEND_VENV)'."; \
		exit 0; \
	fi
	@if [ ! -x "$(BACKEND_UVICORN)" ]; then \
		echo "[SKIP] $(BACKEND_NAME): uvicorn not found in venv '$(BACKEND_UVICORN)'."; \
		exit 0; \
	fi
	@if [ ! -f "$(BACKEND_PATH)/app/main.py" ]; then \
		echo "[SKIP] $(BACKEND_NAME): app/main.py not found."; \
		echo "[HINT] If there is no clear entry point, try: uvicorn app.main:app --reload --port $(BACKEND_PORT)"; \
		exit 0; \
	fi
	@if $(call port_in_use,$(BACKEND_PORT)); then \
		echo "[ERROR] Port $(BACKEND_PORT) is already in use. Please stop the conflicting process before starting $(BACKEND_NAME)."; \
		lsof -iTCP:$(BACKEND_PORT) -sTCP:LISTEN || true; \
		exit 1; \
	fi
	@if [ -f "$(BACKEND_PID)" ]; then \
		PID=$$(cat "$(BACKEND_PID)"); \
		if kill -0 $$PID > /dev/null 2>&1; then \
			echo "[RUNNING] $(BACKEND_NAME) already running with PID $$PID"; \
			exit 0; \
		else \
			echo "[CLEANUP] $(BACKEND_NAME) removing stale PID $$PID"; \
			rm -f "$(BACKEND_PID)"; \
		fi; \
	fi
	@echo "[START] $(BACKEND_NAME) on port $(BACKEND_PORT). Logs: $(BACKEND_LOG) PID: $(BACKEND_PID)"
	@mkdir -p $(LOG_DIR) $(PID_DIR)
	@nohup $(BACKEND_UVICORN) --app-dir $(BACKEND_PATH) app.main:app --host 0.0.0.0 --port $(BACKEND_PORT) --reload >> $(BACKEND_LOG) 2>&1 & echo $$! > $(BACKEND_PID)
	@PID=$$(cat "$(BACKEND_PID)" 2>/dev/null || true); \
	if [ -n "$$PID" ] && kill -0 $$PID > /dev/null 2>&1; then \
		echo "[OK] $(BACKEND_NAME) started with PID $$PID"; \
	else \
		echo "[FAIL] $(BACKEND_NAME) failed to start. First log lines:"; \
		head -n 50 "$(BACKEND_LOG)" 2>/dev/null || echo "(no log yet)"; \
		exit 1; \
	fi

# =====================
# Service: streamlit-chat
# =====================
CHAT_NAME := streamlit-chat
CHAT_DIR := streamlit-chat
CHAT_PATH := $(CHAT_DIR)
CHAT_PORT := 8501
CHAT_VENV := $(CHAT_PATH)/.venv
CHAT_PY := $(CHAT_VENV)/bin/python
CHAT_STREAMLIT := $(CHAT_VENV)/bin/streamlit
CHAT_LOG := $(LOG_DIR)/$(CHAT_NAME).log
CHAT_PID := $(PID_DIR)/$(CHAT_NAME).pid

.PHONY: start-streamlit-chat
start-streamlit-chat: init-dirs
	@if [ ! -d "$(CHAT_PATH)" ]; then \
		echo "[SKIP] $(CHAT_NAME): folder '$(CHAT_PATH)' not found."; \
		exit 0; \
	fi
	@if [ ! -d "$(CHAT_VENV)" ]; then \
		echo "[SKIP] $(CHAT_NAME): Python 3.11 venv not found at '$(CHAT_VENV)'."; \
		exit 0; \
	fi
	@if [ ! -x "$(CHAT_STREAMLIT)" ]; then \
		echo "[SKIP] $(CHAT_NAME): streamlit not found in venv '$(CHAT_STREAMLIT)'."; \
		exit 0; \
	fi
	@if [ ! -f "$(CHAT_PATH)/app.py" ]; then \
		echo "[SKIP] $(CHAT_NAME): app.py not found."; \
		exit 0; \
	fi
	@if $(call port_in_use,$(CHAT_PORT)); then \
		echo "[ERROR] Port $(CHAT_PORT) is already in use. Please stop the conflicting process before starting $(CHAT_NAME)."; \
		lsof -iTCP:$(CHAT_PORT) -sTCP:LISTEN || true; \
		exit 1; \
	fi
	@if [ -f "$(CHAT_PID)" ]; then \
		PID=$$(cat "$(CHAT_PID)"); \
		if kill -0 $$PID > /dev/null 2>&1; then \
			echo "[RUNNING] $(CHAT_NAME) already running with PID $$PID"; \
			exit 0; \
		else \
			echo "[CLEANUP] $(CHAT_NAME) removing stale PID $$PID"; \
			rm -f "$(CHAT_PID)"; \
		fi; \
	fi
	@echo "[START] $(CHAT_NAME) on port $(CHAT_PORT). Logs: $(CHAT_LOG) PID: $(CHAT_PID)"
	@mkdir -p $(LOG_DIR) $(PID_DIR)
	@nohup $(CHAT_STREAMLIT) run $(CHAT_PATH)/app.py --server.headless true --server.port $(CHAT_PORT) --server.address 0.0.0.0 >> $(CHAT_LOG) 2>&1 & echo $$! > $(CHAT_PID)
	@PID=$$(cat "$(CHAT_PID)" 2>/dev/null || true); \
	if [ -n "$$PID" ] && kill -0 $$PID > /dev/null 2>&1; then \
		echo "[OK] $(CHAT_NAME) started with PID $$PID"; \
	else \
		echo "[FAIL] $(CHAT_NAME) failed to start. First log lines:"; \
		head -n 50 "$(CHAT_LOG)" 2>/dev/null || echo "(no log yet)"; \
		exit 1; \
	fi

# =====================
# Service: streamlit-dashboard
# =====================
DASH_NAME := streamlit-dashboard
DASH_DIR := streamlit-dashboard
DASH_PATH := $(DASH_DIR)
DASH_PORT := 8502
DASH_VENV := $(DASH_PATH)/.venv
DASH_PY := $(DASH_VENV)/bin/python
DASH_STREAMLIT := $(DASH_VENV)/bin/streamlit
DASH_LOG := $(LOG_DIR)/$(DASH_NAME).log
DASH_PID := $(PID_DIR)/$(DASH_NAME).pid

.PHONY: start-streamlit-dashboard
start-streamlit-dashboard: init-dirs
	@if [ ! -d "$(DASH_PATH)" ]; then \
		echo "[SKIP] $(DASH_NAME): folder '$(DASH_PATH)' not found."; \
		exit 0; \
	fi
	@if [ ! -d "$(DASH_VENV)" ]; then \
		echo "[SKIP] $(DASH_NAME): Python 3.11 venv not found at '$(DASH_VENV)'."; \
		exit 0; \
	fi
	@if [ ! -x "$(DASH_STREAMLIT)" ]; then \
		echo "[SKIP] $(DASH_NAME): streamlit not found in venv '$(DASH_STREAMLIT)'."; \
		exit 0; \
	fi
	@if [ ! -f "$(DASH_PATH)/app.py" ]; then \
		echo "[SKIP] $(DASH_NAME): app.py not found."; \
		exit 0; \
	fi
	@if $(call port_in_use,$(DASH_PORT)); then \
		echo "[ERROR] Port $(DASH_PORT) is already in use. Please stop the conflicting process before starting $(DASH_NAME)."; \
		lsof -iTCP:$(DASH_PORT) -sTCP:LISTEN || true; \
		exit 1; \
	fi
	@if [ -f "$(DASH_PID)" ]; then \
		PID=$$(cat "$(DASH_PID)"); \
		if kill -0 $$PID > /dev/null 2>&1; then \
			echo "[RUNNING] $(DASH_NAME) already running with PID $$PID"; \
			exit 0; \
		else \
			echo "[CLEANUP] $(DASH_NAME) removing stale PID $$PID"; \
			rm -f "$(DASH_PID)"; \
		fi; \
	fi
	@echo "[START] $(DASH_NAME) on port $(DASH_PORT). Logs: $(DASH_LOG) PID: $(DASH_PID)"
	@mkdir -p $(LOG_DIR) $(PID_DIR)
	@nohup $(DASH_STREAMLIT) run $(DASH_PATH)/app.py --server.headless true --server.port $(DASH_PORT) --server.address 0.0.0.0 >> $(DASH_LOG) 2>&1 & echo $$! > $(DASH_PID)
	@PID=$$(cat "$(DASH_PID)" 2>/dev/null || true); \
	if [ -n "$$PID" ] && kill -0 $$PID > /dev/null 2>&1; then \
		echo "[OK] $(DASH_NAME) started with PID $$PID"; \
	else \
		echo "[FAIL] $(DASH_NAME) failed to start. First log lines:"; \
		head -n 50 "$(DASH_LOG)" 2>/dev/null || echo "(no log yet)"; \
		exit 1; \
	fi

# =====================
# Aggregate targets
# =====================
.PHONY: start-all
start-all: start-backend start-streamlit-chat start-streamlit-dashboard start-frontend
	@echo "[DONE] Attempted to start all services. Check individual [SKIP] notices above and logs in $(LOG_DIR)."

# Explicit aggregate aliases
.PHONY: start stop restart help
start: start-all

stop: stop-all

restart: stop-all start-all
	@echo "[DONE] Restarted all services."

help:
	@echo "Available targets:"; \
	echo "  check                 - Run preflight checks"; \
	echo "  install               - Install frontend deps and set up Python venvs (idempotent)"; \
	echo "  env:frontend          - Create frontend env file skeleton"; \
	echo "  start                 - Start all services"; \
	echo "  stop                  - Stop all services"; \
	echo "  restart               - Restart all services"; \
	echo "  status                - Show status for all services"; \
	echo "  logs                  - Show last 200 lines for all logs"; \
	echo "  logs.frontend         - Show last 200 lines of frontend log"; \
	echo "  logs.backend          - Show last 200 lines of backend log"; \
	echo "  logs.chat             - Show last 200 lines of chat log"; \
	echo "  logs.dashboard        - Show last 200 lines of dashboard log"; \
	echo "  start.frontend        - Start only the frontend service"; \
	echo "  start.backend         - Start only the backend service"; \
	echo "  start.chat            - Start only the streamlit chat service"; \
	echo "  start.dashboard       - Start only the streamlit dashboard service"; \
	echo "  stop.frontend         - Stop only the frontend service"; \
	echo "  stop.backend          - Stop only the backend service"; \
	echo "  stop.chat             - Stop only the streamlit chat service"; \
	echo "  stop.dashboard        - Stop only the streamlit dashboard service"; \
	echo "  clean                 - Remove logs/*.log and pids/*.pid"; \
	echo "  clean-logs            - Remove only log files"; \
	echo "  clean-pids            - Remove only pid files"

# Optional stop targets for convenience
.PHONY: stop-frontend stop-backend stop-streamlit-chat stop-streamlit-dashboard stop-all
stop-frontend:
	@if [ ! -f "$(FRONTEND_PID)" ]; then \
		echo "[NOT RUNNING] $(FRONTEND_NAME): no PID file at $(FRONTEND_PID)"; \
		exit 0; \
	fi; \
	PID=$$(cat "$(FRONTEND_PID)" 2>/dev/null || true); \
	if [ -z "$$PID" ] || ! kill -0 $$PID >/dev/null 2>&1; then \
		echo "[CLEANUP] $(FRONTEND_NAME): cleaned stale PID '$$PID'"; \
		rm -f "$(FRONTEND_PID)"; \
		exit 0; \
	fi; \
	echo "[TERM] $(FRONTEND_NAME) (PID $$PID)"; kill $$PID; \
	for i in $$(seq 1 10); do \
		if ! kill -0 $$PID >/dev/null 2>&1; then echo "[STOPPED] $(FRONTEND_NAME)"; break; fi; \
		sleep 1; \
	done; \
	if kill -0 $$PID >/dev/null 2>&1; then echo "[KILL] $(FRONTEND_NAME) (PID $$PID)"; kill -9 $$PID; fi; \
	rm -f "$(FRONTEND_PID)"

# Per-service alias targets for finer control
.PHONY: start.frontend start.backend start.chat start.dashboard stop.frontend stop.backend stop.chat stop.dashboard
start.frontend: start-frontend
start.backend: start-backend
start.chat: start-streamlit-chat
start.dashboard: start-streamlit-dashboard
stop.frontend: stop-frontend
stop.backend: stop-backend
stop.chat: stop-streamlit-chat
stop.dashboard: stop-streamlit-dashboard

stop-backend:
	@if [ ! -f "$(BACKEND_PID)" ]; then \
		echo "[NOT RUNNING] $(BACKEND_NAME): no PID file at $(BACKEND_PID)"; \
		exit 0; \
	fi; \
	PID=$$(cat "$(BACKEND_PID)" 2>/dev/null || true); \
	if [ -z "$$PID" ] || ! kill -0 $$PID >/dev/null 2>&1; then \
		echo "[CLEANUP] $(BACKEND_NAME): cleaned stale PID '$$PID'"; \
		rm -f "$(BACKEND_PID)"; \
		exit 0; \
	fi; \
	echo "[TERM] $(BACKEND_NAME) (PID $$PID)"; kill $$PID; \
	for i in $$(seq 1 10); do \
		if ! kill -0 $$PID >/dev/null 2>&1; then echo "[STOPPED] $(BACKEND_NAME)"; break; fi; \
		sleep 1; \
	done; \
	if kill -0 $$PID >/dev/null 2>&1; then echo "[KILL] $(BACKEND_NAME) (PID $$PID)"; kill -9 $$PID; fi; \
	rm -f "$(BACKEND_PID)"

stop-streamlit-chat:
	@if [ ! -f "$(CHAT_PID)" ]; then \
		echo "[NOT RUNNING] $(CHAT_NAME): no PID file at $(CHAT_PID)"; \
		exit 0; \
	fi; \
	PID=$$(cat "$(CHAT_PID)" 2>/dev/null || true); \
	if [ -z "$$PID" ] || ! kill -0 $$PID >/dev/null 2>&1; then \
		echo "[CLEANUP] $(CHAT_NAME): cleaned stale PID '$$PID'"; \
		rm -f "$(CHAT_PID)"; \
		exit 0; \
	fi; \
	echo "[TERM] $(CHAT_NAME) (PID $$PID)"; kill $$PID; \
	for i in $$(seq 1 10); do \
		if ! kill -0 $$PID >/dev/null 2>&1; then echo "[STOPPED] $(CHAT_NAME)"; break; fi; \
		sleep 1; \
	done; \
	if kill -0 $$PID >/dev/null 2>&1; then echo "[KILL] $(CHAT_NAME) (PID $$PID)"; kill -9 $$PID; fi; \
	rm -f "$(CHAT_PID)"

stop-streamlit-dashboard:
	@if [ ! -f "$(DASH_PID)" ]; then \
		echo "[NOT RUNNING] $(DASH_NAME): no PID file at $(DASH_PID)"; \
		exit 0; \
	fi; \
	PID=$$(cat "$(DASH_PID)" 2>/dev/null || true); \
	if [ -z "$$PID" ] || ! kill -0 $$PID >/dev/null 2>&1; then \
		echo "[CLEANUP] $(DASH_NAME): cleaned stale PID '$$PID'"; \
		rm -f "$(DASH_PID)"; \
		exit 0; \
	fi; \
	echo "[TERM] $(DASH_NAME) (PID $$PID)"; kill $$PID; \
	for i in $$(seq 1 10); do \
		if ! kill -0 $$PID >/dev/null 2>&1; then echo "[STOPPED] $(DASH_NAME)"; break; fi; \
		sleep 1; \
	done; \
	if kill -0 $$PID >/dev/null 2>&1; then echo "[KILL] $(DASH_NAME) (PID $$PID)"; kill -9 $$PID; fi; \
	rm -f "$(DASH_PID)"

stop-all: stop-frontend stop-backend stop-streamlit-chat stop-streamlit-dashboard
	@echo "[DONE] Attempted to stop all services."

# Cleaning targets
.PHONY: clean clean-logs clean-pids
clean:
	@echo "[CLEAN] Removing logs and PID files..."
	@rm -f $(LOG_DIR)/*.log 2>/dev/null || true
	@rm -f $(PID_DIR)/*.pid 2>/dev/null || true
	@echo "[CLEAN] Done."

clean-logs:
	@echo "[CLEAN] Removing logs in $(LOG_DIR)/*.log"
	@rm -f $(LOG_DIR)/*.log 2>/dev/null || true

clean-pids:
	@echo "[CLEAN] Removing PIDs in $(PID_DIR)/*.pid"
	@rm -f $(PID_DIR)/*.pid 2>/dev/null || true

# Consolidated PHONY targets required by spec
.PHONY: install start stop restart status logs logs.chat logs.dashboard logs.frontend logs.backend check help

