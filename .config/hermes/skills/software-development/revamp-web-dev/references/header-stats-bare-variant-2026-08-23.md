# Header stat presentation: bare values, not cards (2026-08-23)

User correction during the Live Calls header-stats work: the four KPIs
(Calls / Avg duration / Barge-ins / Rated) were parked in the sticky shell
header slot as carded `compact` StatTiles in a fixed `grid-cols-4`. Rejected:
"the cards, remove them i think and only include the values", "or even remove
the fixed size". Cards next to the breadcrumb read cramped (labels touching
card borders, no separation between tiles) and the fixed grid breaks on
narrower windows.

## What landed

New `<StatTile bare>` variant in `ui.tsx`:

- No Card wrapper at all — muted uppercase label + `InfoTip` over the value.
- Value is right-aligned `text-sm font-semibold tabular-nums` (header metadata,
  not a dashboard hero).
- Layout for header stats: `flex flex-wrap items-center justify-end gap-x-5
  gap-y-2` — pairs wrap to a second line on narrow windows instead of squeezing.

live.tsx's `useSetHeaderActions` strip uses this; see
`sticky-table-header-native-scroller.md` for the surrounding pattern.

## Rule of thumb

- Stats IN the shell header (beside breadcrumb) → `bare`, flex-wrap row.
- Stats ABOVE page content (in-page summary strips, e.g. onboarding, goals)
  → keep the `compact` CARD variant; cards are fine there.
