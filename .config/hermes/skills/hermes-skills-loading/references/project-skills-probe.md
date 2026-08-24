# Worked example: revamp-web-interface project skills not in / palette (2026-08)

## Symptom

User's `.agents/skills/` (48 skills: tanstack-*, animate*, argent-*,
migrate-radix-to-base, improve, ...) absent from the desktop app's `/`
palette and `skills_list`.

## Findings

1. Trust was already configured:
   ```
   hermes skills trust /Users/saileshbro/Projects/revamp-web-interface
   → Already trusted ... 96 project skill(s) will load in sessions started inside this repo
   ```
   config.yaml had both repos under `skills.trusted_project_dirs`.

2. The live desktop session still showed none of them. Root cause: the
   session process resolved no project root — its surface cwd was `~`
   (`TERMINAL_CWD=/Users/saileshbro`). Project skills are scanned at session
   start against the *process's* cwd; a session started without repo context
   never gains them retroactively.

3. Probe with explicit TERMINAL_CWD proved the loader works:
   ```python
   os.environ['TERMINAL_CWD'] = '/Users/saileshbro/Projects/revamp-web-interface'
   from agent import skill_utils as su
   su.find_project_root()        # → <repo>
   su.get_project_skills_dirs()  # → [.hermes/skills, .agents/skills]
   from agent.skill_commands import scan_skill_commands
   len(scan_skill_commands())    # → 189 (vs 148 without project)
   ```

4. Six skills were quarantined by the scan-time security guard
   (verdict=dangerous), printed to stderr during scan:
   - `.hermes/skills/argent-tv-interact` — injection ×1
   - `.hermes/skills/dotenv` — credential_exposure, exfiltration, supply_chain
   - `.hermes/skills/dotenvx` — credential_exposure, supply_chain
   - `.hermes/skills/find-animation-opportunities` — injection ×1
   - `.hermes/skills/improve-animations` — injection ×5
   - `.hermes/skills/improve` — execution, injection, persistence

   Diff check: 48 SKILL.md dirs under .agents/skills, 42 registered,
   exactly those 6 missing. Note quarantine hits came from BOTH project
   dirs (.hermes/skills and .agents/skills are both scanned).

## Resolution

- Fresh session anchored to the repo picks up ~42/48 project skills.
- `/reload-skills` does NOT exist as a desktop slash command ("not shown in
  the desktop slash palette" is the app's own error message for it).
- Quarantine has no local override; false positives go upstream.

## Environment notes (may drift)

- venv at `~/.hermes/hermes-agent/venv/bin/python` (not `.venv`).
- `hermes skills trust --help`; trust subcommand takes an optional path.
