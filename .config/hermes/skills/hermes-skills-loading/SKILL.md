---
name: hermes-skills-loading
description: Use when project skills don't show in Hermes' skill list.
---

# Hermes Skills Loading & Visibility

Diagnosing why a skill exists on disk but not in the agent's skill list / slash palette.

## Where Hermes looks for skills

Scan order (first-wins dedup, so earlier takes precedence):

1. **Project skills** — `<repo>/.hermes/skills/` and `<repo>/.agents/skills/`
2. **Profile skills** — `~/.hermes/skills/` (or `$HERMES_HOME/skills/`)
3. **External dirs** — `skills.external_dirs` in config.yaml

## Project skills require ALL of: git root + trust + correct cwd

A project skill loads only when every gate passes:

- **Git root**: `find_project_root()` walks up from cwd (or `$TERMINAL_CWD` if set)
  looking for `.git`. The home directory itself is explicitly NOT a project
  (dotfiles-style home git repos never count).
- **Trust**: repo must be in `skills.trusted_project_dirs` in config.yaml.
  Add with `hermes skills trust /path/to/repo` (run inside the repo or pass path).
  Verify: the command prints "N project skill(s) will load in sessions started
  inside this repo".
- **Surface cwd**: the *running process* must resolve that project root. A live
  desktop chat session whose workdir isn't anchored to the repo scans WITHOUT
  project skills — they will not appear retroactively even if trust was already
  configured. **Fix: start a fresh session inside the repo.** Rescanning alone
  won't help if cwd resolution misses.

## Quarantine (project skills only)

Every project SKILL.md's parent dir is content-scanned at index time
(skills_guard, fail-closed). Verdict `dangerous` → skill silently excluded from
index/list/view/slash. Warnings print to stderr during scan:

```
Project skill quarantined (verdict=dangerous): <path> — <findings>
```

Common false-positive categories for legit ops skills: `injection` (imperative
prompt phrasing), `credential_exposure`/`exfiltration` (dotenv-style skills),
`execution`/`persistence`. Quarantine decisions are not user-overridable locally;
review the flagged SKILL.md and report upstream if it's a false positive.
`caution` verdicts still load — only `dangerous` blocks.

## Diagnosing from CLI

```bash
# What the loader actually sees for a given working dir:
TERMINAL_CWD=/path/to/repo ~/.hermes/hermes-agent/venv/bin/python -c "
import os; os.environ['TERMINAL_CWD']='/path/to/repo'
from agent import skill_utils as su
print(su.find_project_root(), su.is_project_root_trusted(su.find_project_root()))
print(su.get_project_skills_dirs())
from agent.skill_commands import scan_skill_commands
print(len(scan_skill_commands()))"

# Diff which on-disk skills failed to register (quarantined ones are missing):
TERMINAL_CWD=<repo> hermes skills list   # compare against ls .agents/skills
```

## Pitfalls

- `/reload-skills` is a CLI/TUI slash command; it does NOT exist in the desktop
  app's slash palette. In desktop, the equivalent of a rescan-with-new-project
  context is opening a fresh session anchored to the repo.
- A repo being trusted is necessary but not sufficient — see surface-cwd gate above.
- Same-named project skills override profile skills; if a profile skill seems
  stale, check whether a project copy shadows it.
