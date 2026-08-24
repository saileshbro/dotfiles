# Session learnings index (2026-08-23 UI-revamp waves 3–4)

Curator note: overwrite-guards blocked editing the older wave docs this pass,
so late-session corrections live HERE. Fold them into
`sticky-header-bounded-layout-2026-08-23.md` /
`bounded-scroll-wave2-2026-08-23.md` next time they're legitimately open in an
edit session.

## Sticky table headers need a NATIVE scroller (live.tsx, third fix)

A `sticky top-0` `<TableHeader>` only pins against a NATIVE scrolling box.
Base UI's `ScrollArea` viewport silently breaks it — header doesn't pin, card
grows, whole page scrolls ("keep table header consistent sticky"). Fix:

```tsx
// NOT <ScrollArea>:
<div className="border-border min-h-0 flex-1 overflow-y-auto overflow-x-auto rounded-lg border">
  <Table>
    <TableHeader className="bg-muted/50 sticky top-0 z-10">
```

Applied to live.tsx (2026-08-23). Already-native: users.tsx UsersTable,
engagement Memory tab. STILL ScrollArea+sticky — swap when touched:
**onboarding.tsx session table**.

## Header slot takes stat-tile grids

`useSetHeaderActions` accepts any memoized node, including
`<div className="grid grid-cols-4 gap-2">` of compact `<StatTile>`s. live.tsx
parks its scope-following KPI strip there so stats sit top-right beside the
breadcrumb and never scroll away. Memoize like Tabs (identity-driven
registration).

## Scrollbar color parity

Native scrollers render the OS-default BLACK thumb unless tinted — visibly
wrong next to Base UI's gray thumbs. Add
`[scrollbar-color:var(--color-hairline-strong)_transparent]` alongside
`scrollbar-thin` (message-scroller.tsx viewport did this for the chat thread;
user flagged the black chat scrollbar explicitly).

## Regression guard: SelectRail max-h cap

When standardizing SelectRail's width to w-72, its
`max-h-[calc(100dvh-5.5rem)]` cap got dropped → long user lists grew past the
fold and scrolling bled to the page. The cap is load-bearing; verify it
survives any className refactor of SelectRail.

## SelectRail sticky alignment (2026-08-24)

The rail must sit flush under the shell header with NO float gap, and size to its
parent (not content). Two corrections applied during the filter-to-header wave:
- `sticky top-4` → `sticky top-0` (kills the 16px gap above the card).
- `max-h-[calc(100dvh-5.5rem)]` → `max-h-full` + `self-stretch` (cap is just
  "fill your parent"; correct once pages are bounded `h-full`). `self-start`
  (content height) made the rail hang short next to a taller table column — use
  `self-stretch` so it stretches to the row height and still scrolls internally.
The fixed magic `calc` viewport math is no longer needed once every page root is
`flex h-full min-h-0 flex-1`.

## User's design-vocabulary corrections this session

- Feedback list cards must carry real preview content (accordion/collapsible
  with snippet preview), not single-row stubs; heavy detail goes to the drawer.
- All user-list panels share ONE component + width (`SelectRail`, w-72).
- Targets/Coaching sub-tabs must use the house raised `Tabs` primitive, not a
  bespoke underline style — "use similar ui for all".
- Stats strips: compact variant, aligned with rail/table tops.
- In-page title/description rows are deleted app-wide (breadcrumb names the
  page); filters/stats/filters live in the sticky shell header slot.
- When told "use skills", the project's `.agents/skills/` set applies —
  `emil-design-eng` (hierarchy via density, restraint on motion ≤300ms
  ease-out, primitives over hand-rolled controls) + `shadcn` rules
  (compose-don't-reinvent, semantic colors, gap-not-space-y, Collapsible
  primitives not role="button" divs).
