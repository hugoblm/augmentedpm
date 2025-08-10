#!/usr/bin/env bash
# Setup script for Python services
# - Creates Python 3.11 virtualenvs per service if missing
# - Installs requirements from requirements.txt when present
# - Uses venv-local pip paths
# - Idempotent and safe to re-run

set -euo pipefail

services=(
  "backend"
  "streamlit-chat"
  "streamlit-dashboard"
)

python_bin="python3.11"

if ! command -v "$python_bin" >/dev/null 2>&1; then
  echo "[ERROR] $python_bin not found on PATH. Please install Python 3.11 and re-run."
  exit 1
fi

for svc in "${services[@]}"; do
  if [[ ! -d "$svc" ]]; then
    echo "[SKIP] $svc: folder '$svc' not found."
    continue
  fi

  venv_dir="$svc/.venv"
  pip_bin="$venv_dir/bin/pip"
  req_file="$svc/requirements.txt"

  if [[ ! -d "$venv_dir" ]]; then
    echo "[INFO] $svc: creating Python 3.11 venv at $venv_dir"
    "$python_bin" -m venv "$venv_dir"
  else
    echo "[OK]   $svc: venv exists at $venv_dir"
  fi

  if [[ ! -f "$req_file" ]]; then
    echo "[SKIP] $svc: requirements.txt not found. Skipping dependency install."
    continue
  fi

  if [[ ! -x "$pip_bin" ]]; then
    echo "[WARN] $svc: pip not found at $pip_bin (venv may be incomplete). Proceeding to try install anyway."
  fi

  echo "[INSTALL] $svc: installing dependencies from $req_file"
  "$pip_bin" install -r "$req_file"

done

echo "[DONE] Setup complete. You can now run 'make install' or 'make start' as needed."

