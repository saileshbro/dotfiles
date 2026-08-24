# URL-param view state (Observatory) — full-scope convention

Extends the earlier `replace:true` search-sweep (`references/tanstack-fixes-2b23f134.md`).
That doc covered *navigation* params; this covers making **every filter, tab, and
selected item** live in the URL so a refresh or shared link reproduces the exact
view. Grounded in `docs/adr/0076-observatory-url-param-state.md` (accepted 2026-08-24).

## The 9 decisions (all applied)

1. **Scope = everything that defines what is rendered.** Filters, tabs, AND the
   selected item (report, Sheet event, open accordion, profile drawer, doc) → URL.
   Pure-transient UI (hover, "Copied" flash, accordion expand/collapse that is
   *not* itself the selected item) stays `useState`.
2. **Omit at default.** `?status=open` collapses to bare URL (`v === DEFAULT ? undefined : v`).
   Absent = default. Keeps shared links short.
3. **Forgiving validation.** Every enum param: `.optional().catch(undefined)`.
   Hand-edited `?status=bogus` or `?report=<deleted-id>` falls back, never 500s.
   Free-string filters (engagement DecisionsTab) use `z.string().optional().catch(undefined)`
   with empty = no filter.
4. **Named params are bare nouns**: `report`, `doc`, `surface`, `session`, `user`,
   `event`, `detail`, `profile`, `kind`.
5. **Independent per route.** The shared `FeedbackView` (`chat.tsx`) exposes `status`
   through each host route's own schema (`/observatory/chat?tab=feedback&status=all`,
   `/observatory/live?…`, `/observatory/onboarding?…`) — no cross-route leakage.
6. **History semantics**: filter/tab changes → `navigate({ replace: true })`;
   item selection → `push` (Back returns to the list). Auto-preselect (below) also
   uses `replace` so it doesn't spam history.
7. **Extend schemas in place** — no shared param helper, no third-party state lib.
8. Text inputs (`kb` `q`, `users` `q`) sync via `replace: true` per keystroke (server-filtered).
9. **Sort + toggles are in scope.** `users` sort serializes as `id:dir`
   (`last_message_at:desc`); the `quiet` toggle as `quiet=1`.

## Drawer / selection resolution pattern (key by id, not by object)

Drawers previously held full objects in `useState`. To make them shareable, key by
id and resolve the object from already-loaded data:

```tsx
// schema
const searchSchema = z.object({ /* … */ detail: z.string().optional(), profile: z.string().optional() });

// page
const detail = selectedItems.find((it) => it.id === search.detail) ?? null;
const profileFor = groups.find((g) => g.userId === search.profile) ?? null;
const setDetail = (id: string | null) =>
  navigate({ search: (prev) => ({ ...prev, detail: id ?? undefined }) });        // push
```

- **TDZ trap**: the resolved `detail`/`profileFor` lines must come AFTER `groups` /
  `selectedItems` are computed (they read those arrays). Declaring setters early is
  fine; declaring the *resolved values* early throws `used before being assigned`
  (tsc TS2448/2454). Put the find() calls right after the data is built.
- **Preselect without history spam**: when a list should auto-open its first row
  (bug-reports), guard on `if (search.report) return;` then call a `replace:true`
  setter so deep-links win and auto-selection doesn't pollute Back.

## Sort serialization (`id:dir`)

`users` `UsersTable` receives `sort` (string) + `onSortChange`; parse/emit:

```tsx
const [sorting, setSorting] = useState<SortingState>(() => {
  const [id = "last_message_at", dir = "desc"] = sort.split(":");
  return [{ id, desc: dir !== "asc" }];
});
useEffect(() => {                                   // sync if URL changes externally
  const [id = "last_message_at", dir = "desc"] = sort.split(":");
  setSorting([{ id, desc: dir !== "asc" }]);
}, [sort]);
const setSortingUrl = (updater) => {
  const next = typeof updater === "function" ? updater(sorting) : updater;
  const s = next[0];
  onSortChange(s ? `${s.id}:${s.desc ? "desc" : "asc"}` : "last_message_at:desc");
};
// useTable({ state: { sorting }, onSortingChange: setSortingUrl, … })
```

- **Guard the default**: `sort.split(":")` can yield `undefined` `id` →
  `id = "last_message_at"` default, or tsc rejects `string | undefined` for `ColumnSort.id`.
- **Boolean setters break updater form**: once `setQuietOnly` takes a `boolean`
  (URL-synced), the old `onClick={() => setQuietOnly((v) => !v)}` is a type error —
  pass `!quietOnly` instead.

## Lifting local state into a route schema (props-down)

When a sub-component held `useState` for a now-URL-synced value (goals
`FeedbackView` kind/status, engagement `DecisionsTab` filters), add the params to
the **route** `searchSchema` and pass `value` + `onChange` as props:

```tsx
// engagement.tsx schema grew: status/risk/segment/trigger (DecisionsTab)
// DecisionsTab(now) = controlled presentational shell, no internal useState for those.
```

`DecisionsTab` (in `notification-engine.tsx`) stays a shared component; the route
owns the URL and passes setters. `feedbackStatus` is derived per host route
(chat/live/onboarding) from the same shared `FeedbackView`.

## Files touched in the 2026-08-24 sweep

`bug-reports.tsx` (status+report), `feedback.tsx` (detail+profile), `goals.tsx`
(kind+target_status+coaching_status — lifted to props), `engagement.tsx` +
`notification-engine.tsx` (DecisionsTab status/risk/segment/trigger), `kb.tsx`
(q), `users.tsx` (quiet+sort), `meal-logging.tsx` (event), `chat.tsx`/`live.tsx`/
`onboarding.tsx` (FeedbackView status each). Plus `docs/adr/0076-…`.
