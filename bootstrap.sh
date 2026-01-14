#!/usr/bin/env bash
# ForgeVista UAP Core bootstrap

set -euo pipefail

AUTO_YES=0
CHECK_ONLY=0

usage() {
  cat <<'USAGE'
Usage: ./bootstrap.sh [--yes] [--check-only]

Options:
  --yes         Run non-interactively (assume yes for prompts)
  --check-only  Only check requirements (no installs)
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes)
      AUTO_YES=1
      shift
      ;;
    --check-only)
      CHECK_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
  esac
done

info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*"; }
ok()   { echo "[ OK ] $*"; }
fail() { echo "[FAIL] $*"; exit 1; }

confirm() {
  local prompt="$1"
  if [[ "$AUTO_YES" -eq 1 ]]; then
    return 0
  fi
  if [[ -t 0 ]]; then
    read -r -p "$prompt [y/N] " reply
    [[ "$reply" == [yY]* ]]
  else
    return 1
  fi
}

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

REQUIRED_MISSING=0

python_version_ok() {
  python3 - <<'PY'
import sys
major, minor = sys.version_info[:2]
print("%d.%d" % (major, minor))
sys.exit(0 if (major > 3 or (major == 3 and minor >= 11)) else 1)
PY
}

install_python() {
  if [[ "$CHECK_ONLY" -eq 1 ]]; then
    return 1
  fi

  if command -v uv >/dev/null 2>&1; then
    info "Using uv to install Python 3.11..."
    if confirm "Install Python 3.11 with uv?"; then
      uv python install 3.11
      return 0
    fi
    return 1
  fi

  case "$OS_NAME" in
    macos)
      if command -v brew >/dev/null 2>&1; then
        info "Using Homebrew to install Python 3.11..."
        if confirm "Install Python 3.11 with Homebrew?"; then
          brew install python@3.11
          return 0
        fi
      fi
      ;;
    linux)
      if command -v apt-get >/dev/null 2>&1; then
        if confirm "Install Python 3.11 with apt-get (requires sudo)?"; then
          sudo apt-get update
          sudo apt-get install -y python3.11 python3.11-venv
          return 0
        fi
      elif command -v dnf >/dev/null 2>&1; then
        if confirm "Install Python 3.11 with dnf (requires sudo)?"; then
          sudo dnf install -y python3.11
          return 0
        fi
      elif command -v yum >/dev/null 2>&1; then
        if confirm "Install Python 3.11 with yum (requires sudo)?"; then
          sudo yum install -y python3.11
          return 0
        fi
      elif command -v pacman >/dev/null 2>&1; then
        if confirm "Install Python with pacman (requires sudo)?"; then
          sudo pacman -Sy --noconfirm python
          return 0
        fi
      fi
      ;;
    windows)
      warn "Windows detected. WSL is recommended for Claude Code."
      ;;
  esac

  return 1
}

check_python() {
  info "Checking Python (3.11+ required)..."
  if command -v python3 >/dev/null 2>&1; then
    if pyver=$(python_version_ok); then
      ok "Python $pyver found"
      return 0
    else
      warn "Python is installed but version is below 3.11"
    fi
  else
    warn "Python not found"
  fi

  if install_python; then
    if pyver=$(python_version_ok); then
      ok "Python $pyver installed"
      return 0
    fi
  fi

  warn "Python 3.11+ is required. Please install it and re-run."
  REQUIRED_MISSING=1
  return 1
}

install_claude() {
  if [[ "$CHECK_ONLY" -eq 1 ]]; then
    return 1
  fi
  if [[ -n "${CLAUDE_INSTALL_CMD:-}" ]]; then
    info "Using CLAUDE_INSTALL_CMD to install Claude Code..."
    if confirm "Run CLAUDE_INSTALL_CMD now?"; then
      bash -lc "$CLAUDE_INSTALL_CMD"
      return 0
    fi
  fi
  return 1
}

check_claude() {
  info "Checking Claude Code CLI..."
  if command -v claude >/dev/null 2>&1; then
    local ver
    ver=$(claude --version 2>/dev/null | head -1 || true)
    ok "Claude Code found ${ver:+($ver)}"
    return 0
  fi

  warn "Claude Code CLI not found"
  if install_claude; then
    if command -v claude >/dev/null 2>&1; then
      ok "Claude Code CLI installed"
      return 0
    fi
  fi

  warn "Install Claude Code CLI using your organization's approved method, then re-run."
  REQUIRED_MISSING=1
  return 1
}

check_uv() {
  info "Checking uv (optional)..."
  if command -v uv >/dev/null 2>&1; then
    ok "uv found ($(uv --version 2>/dev/null || true))"
  else
    warn "uv not found (optional)"
  fi
}

check_node() {
  info "Checking Node.js (optional)..."
  if command -v node >/dev/null 2>&1; then
    ok "Node found ($(node --version 2>/dev/null || true))"
  else
    warn "Node not found (optional)"
  fi
}

check_wsl() {
  if is_wsl; then
    ok "WSL detected"
  elif [[ "$OS_NAME" == "windows" ]]; then
    warn "Windows detected. WSL is recommended for Claude Code."
  fi
}

info "=== ForgeVista UAP Core Bootstrap ==="
info "Setting up your machine for Claude Code..."

check_wsl
check_python
check_claude
check_uv
check_node

if [[ "$REQUIRED_MISSING" -ne 0 ]]; then
  fail "Setup incomplete. Resolve the missing items and re-run."
fi

ok "Setup complete"
info "Run 'claude' to start using Claude Code"
