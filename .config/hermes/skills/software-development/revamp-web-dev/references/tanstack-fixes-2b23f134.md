# TanStack Router/Query execution notes — fixes applied at 2b23f134 (2026-08-23)

Status of the `plan-tanstack-improvements.md` items (T1–T10), with the exact
patterns that worked. Re-verify line numbers before editing.

## Applied

### T1 — autoCodeSplitting (DONE, biggest win)
- `vite.config.ts`: `TanStackRouterVite({ quoteStyle: "double", autoCodeSplitting: true })`.
- Result: main chunk 1,495 kB → ~317 kB; dozens of per-route chunks; >500kB
  build warning gone.
- Verify it fired: `grep -c lazyRouteComponent src/routeTree.gen.ts` (>0) and
  `ls dist/assets/*.js | wc -l` (>1). Green build alone proves nothing.
- Gotcha: a stale transpiled `vite.config.js` shadowed the `.ts` config so the
  flag did nothing at first. Delete the `.js` mirror if config edits don't take.

### T2 — router error/not-found boundaries (DONE)
- New file `apps/web/src/components/observatory/route-fallbacks.tsx` exporting
  `RouteError` + `RouteNotFound`; wired via
  `createRouter({ routeTree, scrollRestoration: true, defaultErrorComponent,
  defaultNotFoundComponent })` in `main.tsx:12`.
- Design constraints honored: no dependency on route context (may be the thing
  that failed); shows the failing URL via `useRouterState`; entry-only fade
  (double-rAF + `transition-opacity duration-150`) as occasional-frequency UI.
- Lint-clean pattern for Link+Button: Base UI Button has no `asChild`; nesting
  `<Link><Button>` trips jsx-max-depth and raw `<button>` trips react-doctor.
  What passed oxlint clean: styled `<Link className={button-variant classes}>`
  directly (copy the cva classes from button.tsx variants).
- Keep fallbacks in `route-fallbacks.tsx`, NOT inside ui.tsx (already 1034L).

### T3 — QueryClient cache defaults (DONE)
- `lib/trpc.ts`: added `staleTime: 30_000, gcTime: 5 * 60_000` to
  `defaultOptions.queries`. The 30s staleTime is safe because admin liveness
  comes from explicit `refetchInterval` polls (rail badges 60s, traces 30s),
  which override staleness anyway.

### T5 — $userId validateSearch zod-aligned (DONE)
- The page already coerced invalid tabs (`tabSchema.catch("journey").parse()`
  at ~line 1917) — deep-link safety was already there; only validateSearch was
  hand-rolled. Fix: hoist `tabSchema` usage into a `searchSchema = z.object({
  tab: tabSchema.optional() })` and pass it as `validateSearch` directly.
- Type fallout to expect: `navigate({ search: (prev) => ... })` callbacks lose
  their loose `Record<string, unknown>` typing once the schema is real. Type
  handlers as `z.output<typeof searchSchema>["tab"]`, not `string`. Zod v4:
  use `z.output<typeof schema>`, NOT `.Values` (doesn't exist on ZodEnum).
- Tabs onChange emits string: use a named handler with an explicit cast
  (`const onViewChange = (v: string) => setView(v as ...)`) — passes
  jsx-no-new-function-as-prop where an inline arrow doesn't.
- If you remove a now-unused import (`useNavigate`), also merge the duplicate
  `@tanstack/react-router` import line or oxlint flags both.

### T6 — replace:true on search navigations (DONE, all sites)
- Every `navigate({ search: (prev) => ({ ...prev, X }) })` in observatory
  routes now has `, replace: true` before the final `})` — filter/tab/drill-down
  clicks stop polluting history. Verify: `grep -rn 'navigate({ search: (prev)'
  src/routes/observatory/ | grep -cv replace` → 0.
- Multi-line forms exist too (chat.tsx onUserIdChange/onSessionIdChange) —
  grep without `-v replace` misses nothing there but check multiline shapes.

### T5b — `.catch(undefined)` on lab search enums (DONE, found by live testing)

zod `validateSearch` THROWS into the router error boundary when a query param
fails the schema — so `goals?tab=GARBAGE` rendered RouteError ("This page
failed to load"), not the default tab. Fix: append `.catch(undefined)` to every
`z.enum` search field (chat, engagement, goals, live, onboarding — one line
each), coercing garbage to `undefined` = the route's default view. Applied
2026-08-23 after live CDP testing caught it; static audit had missed it
because the page-level `.catch()` coercion masked the validateSearch throw.

## Live verification (DONE 2026-08-23, dev server :3003)

Verified via CDP against the running dev server (see technique below):

| Test | Result |
|---|---|
| `goals?tab=activity` | ✅ hydrates Activity tab (`aria-selected`) |
| `goals` no param | ✅ Journey default |
| `engagement/chat/goals ?tab=GARBAGE` | ✅ coerces to default view (post-fix) |
| `users/extra-segment` | ✅ RouteNotFound + Back to Dashboard |
| cold load | ✅ PanelState skeletons instantly |

### Technique: live deep-link verification over CDP

When `browser_navigate` refuses localhost ("private address"), drive the user's
running Chrome via its DevTools endpoint (check `curl 127.0.0.1:9222/json`):

1. Open a probe tab: `PUT /json/new?url=<target>` → returns tab id.
2. Connect WebSocket `ws://127.0.0.1:9222/devtools/page/<id>`.
3. `Page.navigate`, sleep ~4s for SPA hydration, then `Runtime.evaluate`
   reading `[...document.querySelectorAll('h1')].map(h=>h.textContent)` and
   `document.querySelector('[aria-selected="true"]')?.textContent`.
4. Close the probe tab: `GET /json/close/<id>`. Never touch the user's own tabs.

Script shape: plain node ESM importing the workspace's hoisted `ws` package
(`node_modules/.bun/ws@*/node_modules/ws/index.js`) — no new installs needed.
Keep the eval expressions simple strings; nested-quote escaping inside inline
`node -e` is fragile — write the script to a temp file instead.

## Remaining (not applied)

- T4 beforeLoad auth guard on /observatory layout (render-phase navigate in
  `__root.tsx:21-24` still present). Risk: MED — must test logged-out,
  logged-out-deep-link, and logged-in-visiting-/login paths.
- T7 count endpoints (bugReport.openCount / listUsers limit+lazy palette).
- T8 shared useObsMutation wrapper with sonner onError toasts.
- T9 SelectRail state passthrough (skeleton rows while loading, inline
  ErrorState instead of emptyLabel misuse at live.tsx:92).
- T10 defaultPreload:"intent" (after T4).
