# Sticky header actions + bounded page layout (2026-08-23 wave)

The Observatory shell (`apps/web/src/routes/observatory/route.tsx`) owns ONE
`h-14` sticky header OUTSIDE the inset scroll container. Its right side is a
generic actions slot fed by `useSetHeaderActions`
(`components/observatory/breadcrumb-context.tsx`). Pages park filter
Tabs/dropdowns there so controls never scroll away — "sticky filters" for free,
because the header simply isn't inside any scroller.

## The pattern, per page

1. **Delete the in-page title row** (`<h1>` + description + Tabs in a
   `shrink-0 justify-between` row). The breadcrumb already names the page; the
   user explicitly wants title rows gone, not relocated.
2. **Register the Tabs** into the header:
   ```tsx
   const viewTabs = useMemo(
     () => <Tabs tabs={VIEW_TABS} value={view} onChange={onViewChange} />,
     [view],
   );
   useSetHeaderActions(viewTabs);
   ```
   MUST be memoized — registration is identity-driven (the effect deps on the
   node), a fresh literal per render re-sets provider state every render.
3. **Bound the root**: `<div className="flex h-full min-h-0 flex-1 flex-col">`.
4. Only rails/panes own scrolling: `ScrollArea className="min-h-0 flex-1"`.

## useSetHeaderActions is a keyed REGISTRY

Multiple components can register simultaneously — registrations stack side by
side in the slot (rendered by `HeaderActionsSlot` in route.tsx as
`Object.values(headerActions)` with `gap-3`). Concrete case: Engagement's page
registers its section Tabs AND `DecisionsTab`
(`components/observatory/notification-engine.tsx`) registers its four
FilterSelect dropdowns; both live in the header at once. Each hook instance
mints its own id and unregisters on unmount, so tab switches clean up
automatically. A child section does NOT need coordination with its parent page.

## PanelState breaks flex-height chains (root cause of "whole page scrolls")

`PanelState` (ui.tsx) wraps its data branch in a plain `.om-panel-enter` div.
That div is a normal block inside your flex column: it has no min-h-0, no
flex-1, so children grow it past the viewport and the OUTER inset scroller
scrolls everything. Fix at the call site with an arbitrary variant wrapper:

```tsx
<div className="flex min-h-0 flex-1 flex-col [&>div]:flex [&>div]:min-h-0 [&>div]:flex-1 [&>div]:flex-col">
  <PanelState query={list} …>
    {() => <div className="flex min-h-0 flex-1 gap-4">…rail…detail…</div>}
  </PanelState>
</div>
```

Do NOT change the shared primitive — every page depends on its current shape,
and the loading/empty branches return different structures that don't want
flex classes.

## Matching skeletons

`skeleton={<PageSkeleton />}` must mirror the loaded geometry or resolve
telegraphs as a layout jump: same rail width (`w-72 shrink-0 rounded-lg
border`), version-group headers + card-shaped rows for lists, bordered detail
placeholder. Examples now in-tree: `BugReportsSkeleton`,
`SocialSkeleton` (both bottom of their route files).

## Detail panes are INLINE, not Sheets (bug-reports precedent)

The old Sheet-over-empty-dashed-pane layout wasted the right two-thirds. Now:
bordered `bg-card` pane beside the rail renders `ReportDetail` inline;
unselected state centers the Empty inside the same pane. Inside the detail:

- Top bar (pinned): kind/version/timeAgo badges, title h2, status ButtonGroup,
  build-context `dl` grid (grid-cols-2 sm:grid-cols-4).
- Below: tester note (`shrink-0`), error section (`flex min-h-0 flex-1
  flex-col`, its `<pre>` gets `flex-1 overflow-auto` = full remaining height),
  logs capped `max-h-40`.

## Sidebar toggle jitter + collapsed search symmetry

- `SidebarInset` (ui/sidebar.tsx) needs `transition-[margin] duration-200
  ease-linear` to match the sidebar-gap width animation. Without it the
  inset's ml-0→ml-2 collapse shift snaps in one frame while everything else
  eases — reads as jitter.
- Collapsed search (app-sidebar.tsx): the SidebarInput pill keeps pl-8 with a
  left-pinned icon → asymmetric dead space on the narrow rail. Replaced with a
  real button: expanded = full-width row ("Jump to user…" + ⌘K kbd); collapsed
  (`group-data-[collapsible=icon]`) = centered size-8 icon-only, matching nav
  icon footprint.

## Migration status (2026-08-23)

Done: bug-reports, goals (view Tabs → header, bounded root), social (status
Tabs → header + SocialSkeleton), ai-ops (day Tabs → header, wrapped in
ScrollArea), engagement DecisionsTab (4 filters → header via registry).

NOT yet migrated (still have in-page title rows; two-line change each):
meal-logging, onboarding, live, chat, case-sets, kb, users, traces,
$userId profile. Apply steps 1–4 above per page when asked.
