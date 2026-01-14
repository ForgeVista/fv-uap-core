#!/usr/bin/env bash
# Validate current toolchain without installing anything

set -euo pipefail

info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*"; }
ok()   { echo "[ OK ] $*"; }

OS_NAME="unknown"
case "$(uname -s)" in
  Darwin) OS_NAME="macos" ;;
  Linux)  OS_NAME="linux" ;;
  MINGW*|MSYS*|CYGWIN*) OS_NAME="windows" ;;
  *) OS_NAME="unknown" ;;
 esac

is_wsl() {
  [[ "$OS_NAME" == "linux" ]] && grep -qi microsoft /proc/version 2>/dev/null
}

python_version_ok() {
  python3 - <<'PY'
import sys
major, minor = sys.version_info[:2]
print("%d.%d" % (major, minor))
sys.exit(0 if (major > 3 or (major == 3 and minor >= 11)) else 1)
PY
}

REQUIRED_MISSING=0

info "=== ForgeVista UAP Core Checks ==="

if is_wsl; then
  ok "WSL detected"
elif [[ "$OS_NAME" == "windows" ]]; then
  warn "Windows detected. WSL is recommended for Claude Code."
fi

info "Checking Python (3.11+ required)..."
if command -v python3 >/dev/null 2>&1; then
  if pyver=$(python_version_ok); then
    ok "Python $pyver found"
  else
    warn "Python is installed but below 3.11"
    REQUIRED_MISSING=1
  fi
else
  warn "Python not found"
  REQUIRED_MISSING=1
fi

info "Checking Claude Code CLI..."
if command -v claude >/dev/null 2>&1; then
  ver=$(claude --version 2>/dev/null | head -1 || true)
  ok "Claude Code found ${ver:+($ver)}"
else
  warn "Claude Code CLI not found"
  REQUIRED_MISSING=1
fi

info "Checking uv (optional)..."
if command -v uv >/dev/null 2>&1; then
  ok "uv found ($(uv --version 2>/dev/null || true))"
else
  warn "uv not found (optional)"
fi

info "Checking Node.js (optional)..."
if command -v node >/dev/null 2>&1; then
  ok "Node found ($(node --version 2>/dev/null || true))"
else
  warn "Node not found (optional)"
fi

if [[ "$REQUIRED_MISSING" -ne 0 ]]; then
  exit 1
fi

exit 0
