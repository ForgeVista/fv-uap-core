# ForgeVista UAP Core

ForgeVista UAP Core prepares a machine to run Claude Code.
It checks what is installed, installs missing items when possible, and guides you
through any remaining steps.

## Who this is for
- Non-developers or IT staff who want a simple, repeatable setup
- Teams that need a minimal, auditable bootstrap to run Claude Code

## Prerequisites
- A terminal (macOS Terminal, Windows Terminal, or Linux shell)
- Internet access
- Git installed
- Admin approval if your company requires it for software installs
- Windows users: WSL (Windows Subsystem for Linux) is strongly recommended

## Run this command
```bash
git clone https://github.com/ForgeVista/fv-uap-core
cd fv-uap-core
./bootstrap.sh
```

If you want a non-interactive run (auto-yes to prompts):
```bash
./bootstrap.sh --yes
```

## What to expect
- The script checks for Python 3.11+ and the Claude Code CLI
- Optional tools are detected (uv, Node.js)
- If something is missing, it will either install it (when possible) or tell you
  exactly what to do next
- At the end, you should be able to run `claude`

## Authentication
Claude Code typically requires one of:
- An API key provided by your organization
- A login flow configured by your organization

Follow your internal documentation for authentication steps.

## Troubleshooting
**Python not found or version too old**
- Ask IT to install Python 3.11+ or run the suggested package manager command
- Re-run `./bootstrap.sh`

**Claude Code CLI not found**
- Install Claude Code using your organization's approved method
- Re-run `./bootstrap.sh`

**Windows without WSL**
- Install WSL and re-run the script inside WSL

**Script says "Setup incomplete"**
- The script will list the missing items; install them and re-run
