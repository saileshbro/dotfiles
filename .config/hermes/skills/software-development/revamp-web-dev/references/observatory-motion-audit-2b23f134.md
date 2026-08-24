# Observatory motion/UI audit findings — commit 2b23f134

Full 14-finding audit (senior motion advisor pass against the Emil Kowalski
catalogs) performed 2026-08. Findings-only; nothing fixed yet. Each entry has
evidence, so a fix session can go straight to work. Re-verify line numbers
against current HEAD before editing — file:line drifts.

## Governing catalogs (read before ANY animation work in this repo)

- `~/.claude/skills/improve-animations/AUDIT.md` — eight audit categories with
  exact target values (easing curves, duration budgets, physicality,
  interruptibility, performance, a11y, cohesion, missed opportunities). NEVER
  approximate a value that appears there — copy it verbatim.
- `~/.claude/skills/find-animation-opportunities/SKILL.md` — the restraint Gate
  for category 8 (missed opportunities): every candidate must pass
  frequency → purpose → speed → function; expect to REJECT most; max 5–7
  suggestions per app.

Key target values (verbatim from AUDIT.md, for quick citation):
- `--ease-out: cubic-bezier(0.23, 1, 0.32, 1)` (strong ease-out for UI)
- `--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1)` (on-screen movement)
- `--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1)` (iOS-like drawer curve)
- Budgets: press 100–160ms · tooltips/popovers 125–200ms · dropdowns 150–250ms
  · modals/drawers 200–500ms. UI stays under 300ms. `ease-in` on UI is always
  a finding. Never `scale(0)` — use `scale(0.9–0.97)` + opacity 0.
  Press feedback: `transform: scale(0.97)`, `transition: transform 160ms
  ease-out` (subtle 0.95–0.98). Modals are EXEMPT from the transform-origin
  rule (centered is correct — do not report).

## Findings (ordered by leverage)

1. **[FREQ] ⌘K palette animates open.** `apps/web/src/components/ui/dialog.tsx:56`
   `data-open:animate-in fade-in-0 zoom-in-95` `duration-100`, via CommandDialog
   in `components/observatory/command-palette.tsx:54`. Keyboard-initiated
   100+/day → no animation, ever (Raycast rule). Fix: strip the open animation
   classes from the command-dialog variant.
2. **[PERF] `transition-all` on stock Button.** `components/ui/button.tsx:7` bare
   `transition-all` on the most-rendered element. Fix: explicit
   `transition-[color,background-color,border-color,box-shadow,transform,opacity]`.
3. **[A11Y] Zero prefers-reduced-motion coverage except `.shimmer`**
   (`styles/global.css:500-507`). tw-animate-css ships no reduced-motion gate,
   so all `animate-in`/zoom/slide + Sheet translate run ungated. Fix: base-layer
   media query that collapses transform-bearing animation/transition durations
   (gentler, not zero — keep opacity/color).
4. **[PHYS] Sheet enters with `ease-in-out`** — `components/ui/sheet.tsx:56`
   `duration-200 ease-in-out` symmetric enter/exit. Entrance should be
   ease-out (or `--ease-drawer` token); keep 200ms.
5. **[PERF] Progress bars animate `width` via `transition-all`** —
   `routes/observatory/engagement.tsx:824`. Fix: `transform: scaleX(pct)` +
   `transform-origin: left`, `transition: transform 200ms ease-out` (or at
   minimum narrow to `transition-[width]`).
6. **[TOKENS] No shared motion tokens; durations/curves hand-typed per site**
   (100/120/150/200/1100ms scattered across sheet/dialog/popover/global.css).
   Also: `motion@^13.1.0` in `apps/web/package.json:46` imported nowhere — dead
   dependency. Fix: add the three `--ease-*` tokens + `--duration-fast/base` to
   `@theme`, map primitives and `om-*` utilities onto them; drop or deliberately
   adopt `motion`.
7. **[FREQ] InfoTip tooltip delay stacking** — `ui.tsx:277` every InfoTip wraps
   its own `TooltipProvider`, no delayDuration anywhere; dashboards render rows
   of them. Fix: one provider at the Observatory layout (`route.tsx`), tuned
   delay (150–200ms first, near-0 subsequent).
8. **[UI] 46 raw `<button>` elements bypass Button variants, press feedback
   (`active:translate-y-px`), and focus rings.** Repo mapping: secondary→outline
   sm, destructive-confirm→destructive sm, primary→default sm. Note:
   `om-press` utility (global.css:473) exists for exactly this and is used by
   zero elements. Rail rows that must stay raw: add `om-press` +
   `focus-visible:ring-2 focus-visible:ring-ring/50`.
9. **[UI] Three divergent rail implementations vs SelectRail** — chat.tsx:308
   hand-rolls a duplicate (w-64, ScrollArea); case-sets.tsx:355 rail is NOT
   sticky; meal-logging.tsx:538 uses the convention (`lg:sticky lg:top-0
   lg:self-start`). Fix: migrate chat/case-sets onto `SelectRail` (it already
   has a `header` slot), normalize stickiness.
10. **[UI] Loading conflated with empty** — live.tsx:92
    `emptyLabel={calls.isLoading ? "Loading…" : …}` (errors render as "No
    callers yet", violating the ErrorState contract); case-sets.tsx:346 and
    kb.tsx:187 hide-while-loading pop-in. Fix: PanelState-style passthrough in
    SelectRail; reserve count box height instead of unmounting.
11. **[UI] `outline-none` without focus-visible replacement** — ui.tsx:996
    (SelectRail search), notification-engine.tsx:57-59, $userId.tsx:1395. Global
    base `outline-ring/50` is overridden; 1px border shift is the only focus
    indicator. Fix: `focus-visible:ring-2 focus-visible:ring-ring/50
    focus-visible:border-ring`, matching button.tsx:7.
12. **[UI] Raw palette colors bypass DESIGN.md tokens; `--success` is blue** —
    ui.tsx:243-244 (Badge tones) and 351-352 (StatTile) use raw
    emerald/amber + hand-managed `dark:` variants while `--success/--warning`
    tokens exist (global.css:123-129) — and `--success: #0070f3` is Vercel-blue,
    so "good" is green via raw classes. Decide: re-point `--success` to the
    emerald ramp, or accept blue and swap greens. Centralize in Badge/StatTile.
13. **[PERF] index.html loads render-blocking Google Fonts the app doesn't
    use** — index.html:11-17 Inter + JetBrains Mono from fonts.googleapis.com,
    while global.css:4-5 self-hosts Geist via fontsource and `--font-sans`
    resolves to "Geist Variable" first. Delete the Google Fonts links.
14. **[MISSED-01, gated] PanelState skeleton→data swap teleports** —
    ui.tsx:476-485 hard swap, every panel, every load. Passed the Gate
    (occasional frequency, prevents-jarring-change purpose, ≤200ms). Fix:
    entry-only `@starting-style { opacity: 0 }` + `transition: opacity 150ms
    ease-out` on the data branch. Rejected candidates: ⌘K palette motion
    (keyboard 100+/day), row-hover motion (tens/day, current state correct),
    StatTile stagger (daily dashboard, decoration hinders data), custom drawer
    motion (Sheet owns it), animate-spin refresh icon (standard affordance).

## What was already clean (don't re-report)

Overlays delegate animation to shadcn/Base UI primitives; no `scale(0)`, no
`ease-in` anywhere, no `@keyframes` on interruptible UI, PanelState widely
adopted, popover/tooltip use `origin-(--transform-origin)` correctly.
