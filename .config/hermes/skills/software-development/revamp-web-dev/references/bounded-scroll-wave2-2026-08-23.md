# Bounded scroll, SelectRail unification, page-level dialogs (2026-08-23 wave 2)

Follow-up to `sticky-header-bounded-layout-2026-08-23.md` — read that first for
the base pattern (delete title row → header slot → h-full root → internal
scroll). This doc records the completion sweep and the new traps found during
it. All gates green (tsc -b / build / oxlint JSON REAL_ERRORS 0) after each item.

## Canonical user-list panel = SelectRail

ALL user/tester lists render `<SelectRail>` — never hand-roll a rail again
(onboarding, feedback, meal-logging migrated off custom rails; their `cnRail`
helpers deleted).

- Width token **`w-72`** (288px). Was w-60 / w-64 / 340px across four pages.
- `label="Testers"` renders the master-pane header (uppercase label + live
  count Badge) — pass it, don't rebuild that header by hand.
- **The `max-h-[calc(100dvh-5.5rem)]` cap is LOAD-BEARING.** It got dropped
  while standardizing width; long lists grew past the fold and scrolling bled
  to the page ("whole page scrolls when I scroll the user list"). If you touch
  SelectRail's className, verify the cap survived.
- `emptyLabel` widened to `React.ReactNode` (feedback passes a contextual
  sentence); `meta` slot carries per-row badges.
- Pair with `lg:grid-cols-[minmax(0,288px)_minmax(0,1fr)]`; `items-start`
  lets the sticky rail float beside the scrolling pane.

## Second-wave bounded-scroll specifics

Every observatory page now follows the base pattern. Page-specific notes:

- live.tsx: title block gone; stat strips get `shrink-0` everywhere (a stats
  grid without it participates in flex-shrink and squashes).
- kb.tsx: corpus stats moved into the header slot as a compact one-liner via
  `useSetHeaderActions`.
- Table pages (users, engagement Memory tab): bind root; wrap the `<table>` in
  `min-h-0 flex-1 overflow-y-auto overflow-x-auto` — sticky thead works
  because that div IS the scroll ancestor.
- goals.tsx details: JourneyDetail + ActivityDetail wrapped in an internal
  `ScrollArea` (card feeds must not hold the page hostage); Targets/Coaching
  lists keep StatusFilter pinned (`shrink-0`) outside the ScrollArea.
- chat ConversationsView: **no viewport-height magic numbers on scrollers.**
  The thread carried `max-h-[calc(100dvh-13.5rem)]` — drifted every time chrome
  changed and still let the page scroll. Bound the column instead (h-full
  min-h-0 chain from page root), chip rows `shrink-0`, MessageScroller plain
  `min-h-0 flex-1`, PanelState wrapper pulled into the chain via
  `[&>div]:flex [&>div]:min-h-0 [&>div]:flex-1 [&>div]:flex-col`.

## One dialog per PAGE, not per card (Base UI outside-press trap)

Per-card `<Sheet>`s whose trigger IS the card fight dismissal: clicking another
card fires outside-press closing sheet A AND clicks card B opening sheet B —
the sheet appears to never hide ("close button doesn't work"). Fix: ONE
page-level controlled drawer (`useState<Item|null>`), cards call `onOpen`.
Drawer width tokens: `"xl"` ≈768px dense, `"half"` very dense, `"lg"` profile
summaries. A profile drawer should reuse the user-detail page's queryKey
(`["obs","overview",userId]`) so react-query dedupes.

## Collapsible cards pattern

Base UI `Collapsible` primitives, not role="button" divs. Whole head is one
`CollapsibleTrigger`; chevron inline rotating via
`group-data-[open]/card:rotate-180` (name a group on the root); panel animates
off `h-[var(--collapsible-panel-height)]` +
`transition-[height] duration-200 ease-out data-[starting-style]:h-0
data-[ending-style]:h-0`; collapsed preview hidden when open
(`group-data-[open]/card:hidden`). Human notes read `text-foreground` — they
outrank machine quotes.

## StatTile compact variant

`<StatTile compact>` = text-base value + tighter padding for stat strips
sharing a row with content (summary bar, not hero tiles).
