# Observatory feature-gap map (verified at commit 2b23f134, 2026-08-23)

Evidence base from the first `/improve next` direction audit
(`advisor-plans/plan-improve-next.md`). Re-verify line numbers after any wave
that touches these files, but the structural facts change slowly.

## Where things live

- **Admin API surface**: `packages/api/src/api/routers/observatory.router.ts`
  (~2,635 lines, ~60 `adminProcedure` endpoints) — NOT under `apps/server`,
  which only mounts the tRPC handler. Every write proc takes exactly one id
  (no batch mutations anywhere as of 2b23f134).
- **Shared UI primitives**: `apps/web/src/components/observatory/ui.tsx` —
  includes `useListNav(count)` (~line 551, j/k + arrows, skips text fields)
  and `AnnotationBox` (~line 579, ⌘Enter save / ⌘⇧Enter save-and-advance /
  g/b toggles, attribution line).
- **Command palette**: `components/observatory/command-palette.tsx` — ⌘K,
  users-only search ("No users match." empty state), mounted globally in
  `observatory/route.tsx`.

## What already exists (check before proposing as a gap)

- **j/k keyboard list nav**: exists (`ui.tsx` `useListNav`); consumed by
  `feedback.tsx` only.
- **URL-persisted filters**: every Observatory route has `validateSearch`;
  feedback's source/status/verdict filters are fully URL-driven and shareable
  (`feedback.tsx` ~253-272). Known gap: `users.tsx` quiet-only toggle is local
  `useState`, not a search param.
- **Polling**: `traces.tsx` 30s refetchInterval; header badges + ai-ops 60s;
  dashboard panels are pull-only (no interval, no alerting).
- **Chart**: one chart total (`chart-area-interactive.tsx`, shadcn Chart +
  recharts), 7d/30d toggle, single series, no period-over-period deltas.
- **Annotation workflows**: rich — AnnotationBox routes through all labs
  (onboarding turns, target-recompute, coaching insights, chat traces, unified
  feedback inbox) with reviewed_by/reviewed_at attribution.
- **Engagement engine**: decisions/dispatches ledger with suppression reasons,
  shadow mode, caps, kill switch — heavily instrumented already
  (`notification-engine.tsx` InfoTips carry the domain explanations).

## Open feature gaps confirmed by the audit

1. No proactive alerting/digest (all signals computed pull-only per request).
2. No period-over-period comparison anywhere.
3. Palette can't navigate (users only).
4. No batch/multi-item mutations (sequential keyboard review only).
5. Deep single-user view ($userId.tsx ~2,110 lines) vs aggregate-only cohort
   stats — no cross-tester compare.

## Direction-audit doc format (practiced 2026-08-23)

Written to `advisor-plans/plan-improve-next.md` (not NNN-numbered — it's a
standing options doc, not a findings/execution plan):

```
# /improve next — <surface> Direction Options
- Planned at: commit <sha>, <date>
## Suggestions (4-6)
### N1: <title>
- What & why now (2-3 sentences)
- Evidence: file:line
- Effort: S/M/L · Trade-offs: …
- Not in scope: …   ← explicit scoping inside each suggestion
## Explicitly rejected directions
- <idea>: why not (one line)
```

Rules that made the audit useful: verify each candidate gap against code before
proposing (three of six candidates turned out to partially exist); ground every
suggestion in file:line; keep suggestions as options for the maintainer, never
ranked bugs or auto-promoted execution plans.
