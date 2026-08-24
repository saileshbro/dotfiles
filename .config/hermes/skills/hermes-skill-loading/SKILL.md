---
name: hermes-skill-loading
description: "Use when Hermes skills don't show in the / slash palette."
version: 1.0.0
---

# Hermes Skill Loading & Discovery

Use when the user reports skills not showing up in the `/` command palette, `/skills`, or `skill_view()` — especially repo-local `.agents/skills/` or `.hermes/skills/` entries that exist on disk but aren't loaded. Covers trust gating, workdir anchoring, and scan-time quarantine diagnosis.

## How skill directories resolve

Scan order (first-wins name precedence): **project → local (`~/.hermes/skills/`) → external_dirs**.

Project-local skills load from `<repo>/.hermes/skills/` AND `<repo>/.agents/skills/` (cross-tool convention). Both only apply when ALL of these hold:

1. cwd (the *surface's* working directory, via `TERMINAL_CWD`, not process cwd) sits inside a git checkout — nearest ancestor with `.git`.
2. That root is NOT `$HOME` itself (dotfiles-style home repos are deliberately non-projects).
3. The root is listed in `skills.trusted_project_dirs` in config.yaml (`hermes skills trust <path>`).
4. `skills.project_discovery` is not `false`.
5. The skill passes the scan-time security scanner (see Quarantine below).
6. No core-command name collision (e.g. a skill named `handoff` skips `/handoff` auto-registration).

A live session does NOT re-resolve this at runtime — project skills are picked up at session start. A desktop chat only inherits project skills when its Desktop Project anchors it inside the repo; a surface whose workdir resolves outside any trusted repo loads none (hermes-agent issue #48975 behavior).

## Procedure

1. Confirm the skills exist on disk with valid `SKILL.md` files.
2. Confirm trust: `grep trusted_project_dirs ~/.hermes/config.yaml`, or run `hermes skills trust <repo-root>` (idempotent; prints how many project skills will load).
3. Probe resolution directly with the installed venv python — set `TERMINAL_CWD` to the repo first:

```python
import os
os.environ['TERMINAL_CWD'] = '/path/to/repo'
from agent import skill_utils as su
print(su.get_project_skills_dirs())          # empty = untrusted / no project root
from agent.skill_commands import scan_skill_commands
cmds = scan_skill_commands()                  # prints quarantine warnings
print(len(cmds), sorted(k for k in cmds)[:10])
```

   - Empty dirs → steps 2/4 above failed (trust or workdir anchoring).
   - Dirs present but skill absent from map → quarantine (stderr shows `Project skill quarantined`) or name collision.
4. For the fix: a properly trusted repo needs a NEW session anchored inside it (Desktop Project pointing at the repo path, or CLI launched in the repo). `/reload-skills` rescans but does not re-anchor a surface whose cwd never resolved.

## Pitfalls

- **Quarantine has NO override.** Project skills scanned as `dangerous` vanish from index/list/slash and refuse `skill_view` by name. `--force` explicitly cannot clear dangerous verdicts; there is no per-skill allowlist.
- Common false-positive triggers in legit skills: prose containing "ignore previous instructions" (anti-injection rules), merely mentioning `CLAUDE.md`/`AGENTS.md`, backtick command substitution in documentation text. See references file for real pattern IDs.
- **Workarounds for false positives:** copy the reviewed skill into `~/.hermes/skills/` (profile tier isn't project-quarantined), or point `skills.external_dirs` at a fully-controlled directory (routes around a security control — only for user-owned, reviewed folders). Never edit vendored copies to dodge regexes.
- **Desktop sessions ≠ terminal sessions.** Terminal tool calls inherit their own cwd; the chat surface's project anchor decides skill loading. Fixing one doesn't fix the other.
- Bundled/hub/pinned/user-owned skills can't be modified — if the broken skill is protected, recommend `hermes curator adopt <name>` instead of patching.
- `/reload-skills` may be absent from the desktop slash palette (CLI-only); run the rescan via venv python instead.

## Verification

After fixing, start a fresh session inside the anchored project and check `hermes skills list` (with the repo as workdir) counts project skills, and that the target skill appears in the `/` palette. Quarantined ones stay absent by design.

## References

- `references/quarantine-diagnostics.md` — worked example: exact scanner API calls (`scan_skill`, `scan_skill_cached` signatures differ!), per-finding pattern IDs, and the six quarantined skills found in the revamp-web-interface repo.
