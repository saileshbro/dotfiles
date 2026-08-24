---
name: boneyard-skeleton-capture
version: 1.0.0
author: saileshbro
license: MIT
description: Use when regenerating boneyard skeletons in revamp-web.
metadata:
  hermes:
    tags: [boneyard, skeletons, observatory, revamp-web]
    related_skills: [revamp-web-dev]
---

# Boneyard skeleton capture (revamp-web-interface)

## When to Use
- Regenerating/refreshing skeleton bones (`bunx boneyard-js build`) in the revamp-web-interface repo.
- Adding a new `bone="…"` name to a PanelState.
- Debugging boneyard capture failures (login redirects, invalid cookie fields).

Boneyard (`boneyard-js`) snapshots the real rendered UI into "bones" JSON so skeletons match loaded layout exactly (zero CLS). Wired via the Vite plugin in `apps/web/vite.config.ts`; registry imported in `src/main.tsx`.

## How it's integrated

- `PanelState` (`apps/web/src/components/observatory/ui.tsx`) takes a `bone="name"` prop. When set, boneyard's `<Skeleton>` PERMANENTLY wraps the panel: loading → captured bone layout (hand-made `skeleton` prop as fallback), loaded → children under the identical wrapper. DOM shape never changes between states.
- CRITICAL: children must only render when query data exists. Render fns assume loaded data — passing `children(query.data!)` while loading crashes (this bit once).
- CLI build mode measures the LOADED state (`loading=false`, children rendered) via `[data-boneyard]` markers.

## Capture steps

1. Backend + web dev server running (`bun run dev` in apps/web; note port, often 3004 if 3003 is taken).
2. Mint a session cookie (Better Auth):
   ```
   curl -s -X POST http://localhost:3000/api/auth/sign-in/email \
     -H "Content-Type: application/json" \
     -d '{"email":"bones-capture@rayu.local","password":"<see apps/server/scripts/seed-admin.local.ts>"}' \
     -D - -o /dev/null | grep -io "__Secure-better-auth.session_token=[^;]*"
   ```
   If the account doesn't exist: `cp scripts/seed-admin.local.example.ts scripts/seed-admin.local.ts` (gitignored), fill credentials, `bun run db:seed` from repo root.
3. Paste the token into `apps/web/boneyard.config.json` → `auth.cookies[0].value`.
   - The `__Secure-` prefix REQUIRES `"secure": true` in the cookie object. The `--cookie` CLI flag does NOT pass secure/httpOnly through → Playwright rejects with "Invalid cookie fields". Config-file `auth.cookies` passes objects verbatim to addCookies — use it.
4. Run:
   ```
   cd apps/web && bunx boneyard-js build --url http://localhost:<port> --force
   ```
5. Commit `src/bones/` (registry.ts is auto-regenerated).

## Pitfalls

- Session expires after 7 days → re-mint (step 2).
- Vite plugin's hot-reload watcher spams "[boneyard] captured 0 skeletons / redirected to /login" during captures — harmless; the standalone CLI run with config cookies is authoritative.
- Routes not linked in the sidebar need listing under `routes` in boneyard.config.json.
- Bones are keyed per breakpoint width; Tailwind breakpoints auto-detected.

## Naming a new bone

Add `bone="kebab-name"` to a `PanelState` that already has a geometry-matched hand-made `skeleton` fallback, then re-run capture.
