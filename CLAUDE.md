# Claude Code Context (fv-uap-core)

## Repo Purpose
Bootstrap any machine to run Claude Code with minimal, auditable steps.

## Key Files
- `bootstrap.sh`: main installer/checker (idempotent)
- `scripts/check-installed.sh`: validation only
- `README.md`: non-technical guidance
- `AGENT-README.md`: technical notes

## Guardrails
- Do not add secrets or API keys
- Avoid hidden network calls; keep actions explicit
- Prefer checks before installs
- Keep scripts safe to re-run

## Local Checks
```bash
./scripts/check-installed.sh
```
