# Deferred plan items — execution recipes (2026-08-23)

When the user re-issues a "implement all advisor plans" goal after you reported
done, the fix is to EXECUTE a deferred item, not re-report. Two were closed
late in the 2026-08-23 session. Recipes below.

## M8 — raw `<button>` → stock `<Button>` (006 motion, SHADCN-01)

Premise: ~48 hand-rolled `<button className="…px-3…">` controls bypass the
stock `Button` primitive (no variant/press/focus contract).

Scope rule that kept it safe:
- CONVERT only **standalone action buttons**: reload/back/save/send/refresh,
  segmented toggles (kind/target), status `ButtonGroup` children, quiet-only
  filter, copy-addressed, hide/dismiss.
- DO NOT convert **list-rows, accordion headers, and inline copy triggers**
  (collapsible card headers in goals.tsx, rail rows in chat/users/onboarding/
  case-sets, clickable token/trace rows, breadcrumb segments). These are
  correctly custom — the plan itself rejects "treating lists as buttons."
  After M8 the remaining ~30 raw `<button>`s are exactly these; that is the
  correct end state, not a regression.

Mechanical recipe per file:
1. `grep -rn "<button" src/components/observatory src/routes/observatory` to
   enumerate (count drops 48 → 37 after the standalone ones; leave the rest).
2. Add `import { Button } from "@/components/ui/button";` (and
   `ButtonGroup` from `@/components/ui/button-group` where a manual
   `-ml-px` border-join hack exists — replace the hack with real `<Button>`
   children).
3. Replace the `<button … className="…">…</button>` with
   `<Button type="button" variant="…" size="sm" onClick={…}>…</Button>`,
   mapping: secondary actions → `variant="outline"`, primary/save/send →
   default, armed/destructive → `variant="destructive"`. Keep onClick /
   disabled byte-identical.
4. Segmented toggles: `variant={active ? "secondary" : "outline"}` +
   `className="flex-1 capitalize"`.
5. After edits: `bunx tsc -b` (apps/web) then `bun run build` must both be 0.

Files touched: route-fallbacks, notification-engine, commitments, social,
bug-reports, feedback, users. `cn` may become unused in a file that only used
it for the old button class — check with `grep -c "cn(" <file>` before
deleting the import (don't delete if still used elsewhere).

## U2 — command palette → command surface (plan-case-study-admin-ux)

Premise: `CommandPalette` (command-palette.tsx) navigated users only; ⌘K
should also jump to labs/tabs (Linear/Vercel pattern).

Recipe:
1. Extend the component with an optional prop and a new type:
   ```ts
   export type CommandPaletteAction = { id: string; label: string; hint?: string; onRun: () => void; };
   // in signature: actions?: ReadonlyArray<CommandPaletteAction>;
   ```
2. Render an "Actions" `CommandGroup` before the "Users" group, each as a
   `CommandItem` calling `a.onRun()`. Add `CommandSeparator` between groups
   (import from `@/components/ui/command`). Empty-state text becomes
   "No results." (covers both groups).
3. In `routes/observatory/route.tsx` (the only caller), build `actions` from
   the existing `navGroups` array so the verbs stay in sync with the sidebar:
   flatten every leaf item (including `subItems` with their `search`/tab) into
   `{ id: `${to}::${label}`, label: "Go to <label>", hint: group.label, to, search }`,
   memoized with `useMemo`. Pass `actions={paletteActions.map(a => ({ id, label, hint, onRun: () => commitAction(a) }))}`
   where `commitAction` does `navigate({ to: a.to, search: a.search as never })`.
   `navigate` already comes from `useNavigate()` in that route.
4. Keep the existing `items`/`onSelect` user-jump contract untouched.
5. Do NOT add a "toggle quiet-only" verb — that filter is client-side
   `useState` in users.tsx, not URL-synced, so cross-component wiring would
   need lifting state. Skip to avoid plumbing risk.

Verified green: tsc -b=0, build=✓. Committed as the "U2 command surface" commit.

## MOB-01 — master-detail rails stack on mobile (plan-mobile-responsive)

Premise: chat/$userId/onboarding render their session/user rail side-by-side
with the detail pane at every viewport (`flex items-start gap-4` +
`sticky top-4 w-64` rail), squeezing the detail to unreadable width on
phones. MOB-01 fix sketch: rail becomes a full-width block ABOVE detail
(`flex-col lg:flex-row`) — no new primitives, desktop unchanged.

Recipe (per flagged route):
1. Locate the master-detail container (the `div` that holds the rail + detail
   as siblings). Confirmed sites:
   - chat.tsx:~637 `<div className="flex items-start gap-4">`
   - $userId.tsx:~1692 `<div className="flex h-[calc(100dvh-15rem)] min-h-104 gap-4">`
   - onboarding.tsx:~153 `<div className="flex min-h-0 flex-1 items-start gap-4">`
2. Change to `flex flex-col gap-4 lg:flex-row lg:items-start`. For $userId
   also drop the fixed height on mobile so it can scroll naturally:
   `flex h-auto min-h-104 flex-col gap-4 lg:h-[calc(100dvh-15rem)] lg:flex-row`.
   (`lg:flex-row` keeps desktop pixel-identical; `flex-col` is mobile-only.)
3. ALREADY COMPLIANT — do NOT touch: case-sets.tsx & meal-logging.tsx use
   `grid min-h-0 flex-1 gap-4 lg:grid-cols-[16rem_1fr]` (stack natively below
   lg); users.tsx is already a full-width `flex-col` table (no side-by-side
   rail). MOB-01 evidence overstated scope for these three — verify each cited
   site before editing (same lesson as the MOB-05 premise check).
4. After edits: `bunx tsc -b` + `bun run build` must both be 0.

Verified green: tsc -b=0, build=✓. Committed as the "MOB-01 master-detail
rails stack on mobile" commit.

### MOB-05 postscript (why the decisions table stays unwrapped)
plan-mobile-responsive MOB-05 says "wrap each table in overflow-x-auto." That
breaks plan 002's sticky decisions-table header: an `overflow-x-auto` ancestor
becomes the sticky containing block, so `sticky top-0` sticks to that
auto-height div and never fires. Resolution used: leave
`notification-engine.tsx`'s DecisionsTab table unwrapped; the responsive risk
is already mitigated on the real tables by `hidden sm:table-cell` column
hiding (users/feedback/goals/onboarding all use it). Wrap only a table whose
sticky header is NOT inside an overflow ancestor — and confirm by grepping the
other plan doc for the same file first (cross-track contradiction rule).
