# Executing the 25-doc advisor-plans wave (against 2b23f134)

The user handed over all 25 `advisor-plans/*.md` at once ("make the changes
according to each of these plans"). What follows is the execution record plus
the reusable patterns and version traps that surfaced. Consult before picking
up any remaining item from that wave.

## Reality check on scope

25 docs is far more than one session executes. What worked: cluster the docs by
*track* (motion / security / TanStack / a11y-mobile-error), execute a track to
completion, run `bunx tsc -b` after each cluster, and report per-doc status
including what was NOT touched. Do not attempt doc-by-doc serial execution —
the findings interleave across the same files and you will re-edit sites.

Clusters executed: 006 motion sweep (M1–M7, M11, M13 + A11Y-02), security
(SEC-01/02/03/05/07 + DEEP-01 + ARCH-01/02), TanStack (T3b/T4/T7/T8/T9/T10),
a11y-mobile (A11Y-03/05/07, MOB-02/05), plan 002's elevation-resolve.
NOT done: 001/003/004 residuals, most QUICK/DEEP items, plan-case-study-admin-ux,
full ERR-03 `as Any` sweep (spot-checked only).

## Gates actually run

`bunx tsc -b` (apps/web) = 0, `bunx tsc --noEmit` (packages/api) = 0,
`bun run typecheck` = 0, `bun run fmt` applied. **`bun run build` and
`bun run test` were never run** — do not assume they are green.

Note: `bun run typecheck` at the root only exercised 2 packages (turbo cache
scope). Run `bunx tsc` per-app when you need real coverage.

Pre-existing and NOT yours: `apps/server/src/live-call-registry.test.ts` type
errors (reproduced with all changes stashed).

## Version / primitive traps hit

- **react-query 5.101 mutation callbacks take FOUR args**:
  `(data, variables, onMutateResult, context)`. A wrapper forwarding only three
  fails `TS2554: Expected 4 arguments, but got 3`. Signatures live in
  `node_modules/.bun/@tanstack+query-core@5.101.4/.../\_tsup-dts-rollup.d.ts`
  (`grep -n "onSuccess?: (data: TData" -A5`). The top-level
  `@tanstack/query-core/build/modern/types.d.ts` only re-exports aliases — the
  real shapes are in the rollup file.
- **`CardTitle` (components/ui/card.tsx) is a plain `div` and accepts NO
  `render` prop.** `render={<Heading />}` → `TS2322`. To give a card title real
  heading semantics, render the `hN` element *inside* `CardTitle` and keep the
  stock primitive untouched.
- `font-inherit` and `leading-inherit` are **not** Tailwind utilities. Use
  concrete values (`text-sm leading-snug font-semibold`).
- A generic mutation wrapper defaulting `TVariables` to `unknown` breaks
  zero-arg `.mutate()` call sites. Pin explicitly:
  `useObsMutation<Awaited<ReturnType<typeof x.mutate>>, void>({…})`.
- **`<Toaster />` from `components/ui/sonner` was never mounted.** Any
  toast-based error surfacing silently no-ops until it is added to
  `routes/__root.tsx`. Check this before building on toasts.
- **Removing a per-instance provider obliges you to mount one upstream.**
  Stripping `TooltipProvider` out of `InfoTip` (006 FREQ-02/M7) requires adding
  one wrapping `SidebarProvider` in `routes/observatory/route.tsx`, plus its
  closing tag and import — otherwise every tooltip in the app dies.
- Narrowing an env guard orphans the old constant: renaming `is_dev` →
  `is_local_dev` in `apps/server/src/index.ts` left `is_dev` unused, which
  fails lint. Grep for the old name after any guard rename.

## Reusable patterns landed

### `useObsMutation` (apps/web/src/hooks/use-obs-mutation.ts)

House wrapper for T8 / DATA-06 / ERR-04. Baseline was **29 `useMutation` call
sites with zero `onError`** — every failure was silent. Wrapper takes
`invalidateKeys`, `errorTitle`, optional `successMessage`; calls the site's own
`onSuccess`/`onError` last so they can extend defaults. Because the wrapper
owns invalidation, adopting it usually orphans the local
`useQueryClient()` (`qc` / `queryClient`) — delete it and trim the import in
the same edit or lint fails.

### Early-return state gate instead of a ternary chain

oxlint's `eslint(no-nested-ternary)` is an **error** here, and the natural
loading → error → empty → data slot chain trips it. Extract a sub-component
with early returns (as done for `SelectRailBody` backing `SelectRail`) rather
than nesting `? :`. Same lesson in `md.tsx`: replace a nested ternary with an
`if/else` around `out.push(...)`.

### Security helpers

- `packages/api/src/regex.ts` → `escape_regex()`. Wire it anywhere user or
  LLM-supplied text reaches a Mongo `$regex` / `new RegExp()`. Only two such
  sites existed (`supplement.service.ts` name match,
  `observatory.router.ts` `listUsers` search); the rest are static patterns.
- `md.tsx` → `isSafeHref()` allows only `http(s):` and `mailto:`; unsafe
  schemes degrade to the plain-text label. Verified against 14 cases including
  uppercase and tab-obfuscated `javascript:`.
- `apps/web/public/_headers` now carries the Cloudflare Pages security headers
  (SEC-05).

### Query-key vocabulary

T3b is complete: the `["observatory", …]` family is **gone** — all keys are
`["obs", …]`. Keep new keys on `["obs", …]`; `grep -rn '\["observatory"' src`
must stay at 0.
