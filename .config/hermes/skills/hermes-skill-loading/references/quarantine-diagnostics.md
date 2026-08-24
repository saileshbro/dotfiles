# Quarantine & Skill-Loading Diagnostics — Worked Example

Session of 2026-08-23, repo `~/Projects/revamp-web-interface`. 96 project skills across `.hermes/skills/` + `.agents/skills/`; repo already trusted. Symptom: none appeared in the desktop `/` palette; six specific ones were hidden everywhere.

## Root causes found (in order)

1. **Unanchored surface.** The chat surface's workdir resolved to `$HOME`, not the repo → `find_project_root()` returned `None` → trust never consulted → zero project skills loaded. Trust was never the problem.
   Probe (venv python, note the env var must be set BEFORE imports use it):
   ```python
   import os
   os.environ['TERMINAL_CWD'] = '/Users/saileshbro/Projects/revamp-web-interface'
   from agent import skill_utils as su
   print(su.find_project_root())        # None = unanchored; path = OK
   print(su.is_project_root_trusted(root))
   print(su.get_project_skills_dirs())
   ```
   With `TERMINAL_CWD` set, rescan went 148 → 189 slash commands and all 48 `.agents/skills/` entries registered.

2. **Scan-time quarantine** hid exactly six skills even after anchoring:
   | Skill | Findings |
   |---|---|
   | dotenv | credential_exposure, exfiltration, supply_chain |
   | dotenvx | credential_exposure, supply_chain |
   | improve | execution, injection, persistence |
   | improve-animations | injection ×5 |
   | find-animation-opportunities | injection |
   | argent-tv-interact | injection |

## Scanner API notes

- `tools.skills_guard.scan_skill(path: Path)` — direct scan, no cache. Returns `ScanResult` with `.verdict`, `.findings[]`.
- `scan_skill_cached(skill_path, source='community', *, source_url='', cache_dir=None)` — DIFFERENT signature (2 positional max); returns `(result, provenance_dict)`. Cache lives under `~/.hermes/cache/project_skill_scans/`.
- Each finding has `pattern_id, severity, category, file, line, match, description`.
- Report printer: `format_scan_report(result)`.

## False-positive anatomy (`improve` SKILL.md)

| pattern_id | Triggered by | Why it's a false positive |
|---|---|---|
| prompt_injection_ignore | Hard Rule 6 quoting "ignore previous instructions" as something to REJECT | The rule is anti-injection; regex matches the literal phrase regardless of intent |
| agent_config_mod ×2 | Prose telling the agent to READ `CLAUDE.md`/`AGENTS.md` during recon | Read guidance, not config writes |
| backtick_subshell | `` `$(git merge-base …)` `` inside backticks in a doc table | Documentation text, not executable script |

The `improve` skill is read-only-by-design (its own Hard Rules forbid edits outside `plans/`) — verdict DANGEROUS anyway, because project quarantine is fail-closed with no override (`--force` cannot clear dangerous for community/trusted sources).

## Resolution paths

- Anchoring fix: Desktop Project pointing at the repo path, or CLI launched inside the repo; project skills load on NEXT session start.
- Quarantine false positives: copy reviewed skill to `~/.hermes/skills/<name>/` (profile tier not scanned this way), or `skills.external_dirs` for user-owned reviewed folders. Do NOT rewrite vendored skills to dodge regexes.
- Name collision: skill named same as core command (e.g. `handoff`) silently skips slash registration; still loadable via `skill_view`.
