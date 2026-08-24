# PanelState skeleton / CLS invariant

`PanelState` (in `@/components/observatory/ui.tsx`) is the ONE resolver for
loading | error | empty | data. Its render branches:

```tsx
if (query.isLoading)
  return (<>{live}{skeleton ?? <Skeleton className="h-24 w-full" />}</>);
if (query.isError)   return (<>{live}<ErrorState … /></>);
if (query.data === undefined || isEmpty) return <Empty>{empty}</Empty>;
return <div className="om-panel-enter">{children(query.data)}</div>;  // data branch
```

`.om-panel-enter` is `display:block` + a 150ms opacity `@starting-style` fade —
it carries **no flex/height semantics**. This has two consequences that bite
every bounded (non-whole-page-scroll) route:

## Failure mode 1 — skeleton→loaded layout shift (CLS)

The skeleton branch is a **direct child** of whatever wrapper `PanelState`
sits in. The data branch is wrapped in `.om-panel-enter` (also a child, but
block). If the consuming container does not give BOTH branches the same
`flex-1` box, the skeleton and the loaded content occupy different heights →
the page jumps on load.

- **users.tsx (2026-08-24)**: `PanelState` was a direct child of
  `flex h-full min-h-0 flex-1 flex-col` with **no adapter**, skeleton was a
  fixed `Skeleton h-96` (384px) while the loaded `UsersTable` was
  content-height → 384px→content jump.
- **goals.tsx JourneyView (2026-08-24)**: loading showed a bare
  `<Empty>Loading timeline…</Empty>` (tiny, centered) and loaded a full-height
  `ScrollArea` feed → small→full jump.

Fix for both: make the skeleton fill the SAME box the loaded content fills.
Skeleton becomes `<Skeleton className="h-full min-h-96 w-full rounded-lg" />`
so it occupies the full bounded height, and the wrap gets
`flex min-h-0 flex-1 flex-col [&>div]:flex [&>div]:min-h-0 [&>div]:flex-1 [&>div]:flex-col`.

## Failure mode 2 — loaded scroller not height-bounded (whole page scrolls)

The loaded content almost always contains a `ScrollArea min-h-0 flex-1` (table,
feed) that needs a **flex parent with a bound** to scroll internally. If
`PanelState`'s `.om-panel-enter` div is not pulled into the flex chain, the
`ScrollArea flex-1` has no flex parent → collapses to content height and the
WHOLE PAGE scrolls instead. This is the exact bug the `live.tsx` / `chat.tsx`
/ `bug-reports.tsx` `[&>div]` adapters were added to fix — but `users.tsx`
was missed until the 2026-08-24 verification pass.

## The invariant (apply whenever PanelState is in a bounded flex column)

Wrap `PanelState` in the adapter so BOTH branches fill:

```tsx
<div className="flex min-h-0 flex-1 flex-col [&>div]:flex [&>div]:min-h-0 [&>div]:flex-1 [&>div]:flex-col">
  <PanelState query={q} skeleton={<Skeleton className="h-full min-h-96 w-full rounded-lg" />}>
    {(data) => <ScrollArea className="min-h-0 flex-1">…</ScrollArea>}
  </PanelState>
</div>
```

The `[&>div]` arbitrary variants target `>div` — so they hit BOTH the
skeleton (if it's a `<Skeleton>`, which renders a div) AND the data branch's
`.om-panel-enter` div. Both get `flex-1` and the same height → no CLS, and the
inner `ScrollArea flex-1` finally has a flex parent.

**Routes that already use this adapter (don't re-add):** bug-reports.tsx,
chat.tsx (FeedbackView), live.tsx. **Routes verified OK without an adapter
because PanelState sits INSIDE an already-bounded `ScrollArea`** (the ScrollArea
is the flex child; skeleton + data both flow inside it, no height jump):
social.tsx, engagement CohortStrip (`PanelState` is the grid child, skeleton
and data share the same `grid` wrapper), kb.tsx (skeleton + data share the same
`grid-cols-[380px_1fr]`), feedback/meal-logging stats (grid rows, both
branches match).

## Skeleton geometry-match audit (verification method)

To verify "no layout shift before/after load," read the `skeleton={…}` JSX and
the `children`/loaded container JSX for the SAME route and compare:

1. **Root flex/grid classes must be identical** between skeleton and loaded.
   (bug-reports: both `flex min-h-0 flex-1 gap-4` + `w-72` rail. kb: both
   `grid min-h-0 flex-1 grid-cols-[380px_1fr]`. engagement cohort: both
   `grid grid-cols-2 … xl:grid-cols-7`.)
2. **Heights must match.** Fixed-height skeletons (`h-24`, `h-96`) must equal
   the loaded element's rendered height. `StatTile size="sm"` Card ≈ 94–100px,
   so a `h-24` (96px) skeleton is marginal-but-OK; if the loaded tile wraps a
   `sub`/`info` line it can exceed 96px and nudge the row. Prefer `h-full`
   skeletons inside a `flex-1` wrapper (fills the real box) over guessing a px.
3. **Bare `<Empty>` as a loading placeholder is a CLS bug** — it has no
   geometry. Replace with a `h-full min-h-96` Skeleton (goals JourneyView
   fix).

## Transient inspection overlays vs deep-linkable items

Per ADR-0076 (full-scope URL state), an on-screen item that is an *object-state
inspection overlay of an already-linkable parent* may stay local IF flagging
it. Concrete 2026-08-24 case: `chat.tsx` `ConversationsView` `activeTurn`
(per-message TurnTraceDetail) — its parent *session* is linkable via `?session=`,
and the turn detail is object-state (resolved from loaded data, not an id), so
it was left local (treated as transient like the copied-flash). Flag such
cases for the user rather than silently leaving them, since they ARE on-screen
items. (Contrast: `$userId.tsx` `session` + `trace` WERE promoted to URL params
because both are id-resolvable and represent a primary selection/trace.)
