# shadcn `improve` skill — follow-up recipe (2026-08-23)

The `.claude/skills/improve/SKILL.md` is a **strictly read-only senior advisor**
(Hard Rule 1: never edits code). When the user says "run the improve skill and
follow its suggestions," the contract is: run it read-only to produce findings,
then YOU implement the top safe suggestion as the executor. The skill
invocation itself changes nothing.

## How to "run" it in practice

1. Load `.claude/skills/improve/SKILL.md` and follow its Phase 1–3 (recon +
   audit + vet). It produces a vetted findings table (impact ÷ effort, by
   confidence) and, for `next`/direction, separate options.
2. Pick the highest-leverage finding that is **grep-provable and low-risk** to
   execute (avoid MED/L-risk refactors or anything needing server endpoints
   unless the user explicitly greenlit them).
3. Implement it as a normal code change, verify with `tsc -b` + `build` on the
   touched package, and flip the plan doc's status marker.

## Recipe executed this session: DEEP-04-style regex-escaping DRY (SEC-03)

The improve pass surfaced duplicated regex-escaping logic as tech debt.
SEC-03 had already introduced `escape_regex` in `packages/api/src/regex.ts` as
the single source of truth, but two files reimplemented the escape inline:

- `packages/api/src/api/services/nutrition/integration/fetcher.ts:43`
  `const escaped = head.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");`
- `packages/api/scripts/bench-identity.ts:50` (same inline escape)

Fix:
1. Add the import. Path depends on depth:
   - From `src/api/services/` → `import { escape_regex } from "../../regex";`
     (matches `supplement.service.ts:3` — copy this form).
   - From `src/api/services/nutrition/integration/` →
     `import { escape_regex } from "../../../../regex";`
   - From `scripts/` (outside `src/`, uses `../src/...` imports) →
     `import { escape_regex } from "../src/regex";`
2. Replace the inline `head.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")` with
   `escape_regex(head)`. Keep the surrounding `new RegExp(\`^${escaped}\`)`
   interpolation — only the escaping moves to the shared fn.
3. Verify: `cd packages/api && bunx tsc -b` (exit 0) and
   `cd apps/web && bun run build` (exit 0).

Spurious lint note: running `oxlint` on a single file reports
`error TS5112: tsconfig.json is present but will not be loaded if files are
specified on commandline` — that is a single-file-lint artifact, NOT a real
error. Confirm with the project `tsc -b` instead.

## Grep anchor for future improve passes

`grep -rn "new RegExp" packages/api/src apps/web/src` enumerates every regex
construction. Flag any that interpolate user/DB-derived strings WITHOUT going
through `escape_regex` — those are the SEC-03 regressions to fix. (The
`conversation-signals.ts` and `thinking-steps.ts` `new RegExp` calls
interpolate constant regex fragments, not user input — safe, leave them.)
