# Executing advisor plans (advisor-plans/NNN-*.md)

Advisor plans are written by a planning pass against a specific commit and
handed to an executor (often a subagent) as the full task spec. Plans follow a
fixed anatomy; the executor contract is strict.

## Plan anatomy

- Header: plan number/slug + **commit it was written against**. If the working
  tree has drifted far from that commit, re-verify "Current state" excerpts
  before editing.
- **Why** — user-visible motivation; read it, it disambiguates intent when a
  step is ambiguous.
- **Current state (verified)** — quoted excerpts with line numbers.
- **Changes** — numbered steps, often with literal class strings or code blocks
  to use verbatim.
- **Out of scope** — explicit do-not-touch list (e.g. "surface rail untouched",
  "no new filtering"). Treat as hard boundaries.
- **Verification gates** — exact commands + expected output (`tsc -b` exit 0,
  `bun run build` → `✓ built`, grep proves a symbol is gone).
- **Escape hatches — STOP and report if…** — pre-authorized abort conditions.
  If one triggers, STOP and report findings exactly instead of improvising a
  workaround.
- **Maintenance note** — constraints future changes in that area must keep.

## Executor contract

1. Read the plan file completely before touching anything.
2. Work ONLY in files the plan names.
3. Before editing, read every referenced file/primitive the plan depends on
   (stock components under `apps/web/src/components/ui/`, shared observatory
   primitives) so variant/prop choices match reality, not memory.
4. Run gates exactly as written, from the directory the plan specifies.
5. Report back: changes made, gate results (with real output), deviations and
   judgment calls — lead with outcomes, bullets over paragraphs.

## Judgment-call precedents (plan 004, case-sets)

These were accepted deviations — reuse the reasoning patterns:

- Plan said group headers use "sticky uppercase label style"; implemented as
  card headers OUTSIDE each group's ScrollArea (always visible, count badge)
  — functionally sticky, matches the master-pane skeleton the same plan asked
  for. When two plan requirements conflict, satisfy the structural one and say
  so in deviations.
- Plan's button mapping didn't cover every raw button (Cancel). Extended the
  mapping along its own axis (Cancel ≈ Edit ≈ outline sm) rather than leaving
  a raw button behind — the gate greps for the old constants.
- Content preservation: when a step deletes a card carrying an `info={<InfoTip>}`
  explainer, reattach that copy to the nearest surviving header instead of
  dropping admin-facing copy silently. Note it in deviations.
- Visual-only gates (e.g. "does not scroll away", "no bad overflow") can't be
  exercised without a running backend/data. Do NOT claim them verified; run
  what's runnable statically, then flag the untested gate explicitly and note
  any risk worth an eyeball (e.g. dense StatTile grids at a narrow column).
