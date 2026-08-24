# Sticky table headers: native scroller required (2026-08-23 live.tsx fix)

Follow-up to `sticky-header-bounded-layout` + `bounded-scroll-wave2`. The
bounded-scroll sweep left one class of bug: table pages that kept Base UI's
`ScrollArea` around the `<table>` with a `sticky top-0` `<TableHeader>`.

## Root cause

CSS `position: sticky` pins against the nearest scrolling ancestor. Base UI's
ScrollArea viewport is a transformed/managed box — sticky inside it does NOT
behave like sticky against a native `overflow-y-auto`. Result: header doesn't
pin, rows push the card taller, page-level scroll re-engages ("whole page is
scrolling… keep table header consistent sticky").

## Fix pattern (live.tsx, applied 2026-08-23)

Replace:

```tsx
<ScrollArea className="min-h-0 flex-1 rounded-lg border">
  <Table>
    <TableHeader className="bg-muted/50 sticky top-0 z-10">
```

with a native scroller:

```tsx
<div className="border-border min-h-0 flex-1 overflow-y-auto overflow-x-auto rounded-lg border">
  <Table>
    <TableHeader className="bg-muted/50 sticky top-0 z-10">
```

Now: header pinned, only body rows scroll, page never scrolls. Already-native
sites (no change needed): users.tsx UsersTable, engagement Memory tab.

**Still ScrollArea+sticky (swap when touched): onboarding.tsx session table.**

## Stats in the header slot

`useSetHeaderActions` accepts any node — including stat tiles:

```tsx
const headerStats = useMemo(
  () => (
    <div className="grid grid-cols-4 gap-2">
      <StatTile compact label="Calls" value={visible.length} info={…} />
      …
    </div>
  ),
  [visible.length, …],
);
useSetHeaderActions(headerStats);
```

Memoize like Tabs (identity-driven registration). live.tsx uses this so its
scope-following KPI strip never scrolls away and frees the column for the
full-height table. Same treatment candidate: onboarding's compact stat strip.

## Related: scrollbar color parity

Native scrollers show the OS-default black thumb unless tinted. Match the gray
Base UI thumbs with `[scrollbar-color:var(--color-hairline-strong)_transparent]`
next to `scrollbar-thin` (done in message-scroller.tsx viewport).
