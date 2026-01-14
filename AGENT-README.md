# ForgeVista UAP Core (Agent Notes)

## Purpose
This repository provides a minimal, auditable bootstrap for running Claude Code.
The design favors idempotent checks and minimal installation side effects.

## Scripts
- `bootstrap.sh`
  - Orchestrates checks and optional installs
  - Intended for human-friendly, guided setup
- `scripts/check-installed.sh`
  - Read-only validation (no installs)

## Supported Platforms
- macOS
- Linux
- Windows via WSL (recommended)

## Requirements
- Python 3.11+ (required)
- Claude Code CLI (required)
- uv (optional)
- Node.js (optional)

## Script Architecture
`bootstrap.sh` follows a "Check -> Install if missing -> Re-check" pattern:
- `check_python`
- `check_claude`
- `check_uv` (optional)
- `check_node` (optional)
- `check_wsl` (Windows guidance)

## Behavior and Idempotency
- Only attempts installation if a component is missing or below minimum version
- Uses user-level installers when available (e.g., `uv`)
- Avoids sudo unless required by the platform package manager
- Safe to run multiple times

## Configuration Flags
- `--yes`: non-interactive mode (auto-yes to prompts)
- `--check-only`: checks only, no installs

Environment variables:
- `CLAUDE_INSTALL_CMD`: if set, used to install Claude Code
  - Example: `CLAUDE_INSTALL_CMD="<org-approved install command>"`

## Exit Codes
- `0`: all required components present
- `1`: missing required components
- `2`: invalid arguments

## Error Handling
- Missing requirements set a global flag and fail at the end
- Installation failures leave clear instructions to re-run after fixes

## Development Notes
- Keep scripts POSIX-friendly where practical
- Do not add secrets or hard-coded credentials
- Favor explicit messaging over silent behavior
