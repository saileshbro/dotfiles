---
name: native-app-launch-perf
description: Use when an Expo/RN app launches slowly before any JS runs.
tags: []
---

Diagnosing and fixing the *native* (pre-JS) portion of React Native/Expo app launch, plus how to ship source patches to native dependencies in this bun monorepo.

## When to reach for this

JS-side profilers (Metro logs, bundle timings) show nothing wrong but cold launch is still slow. In the rayu.ai app roughly half of launch time elapsed before Metro ever received a bundle request. Standard tools can't see that phase: Instruments needs a running process to attach, Metro logs start only when the bundle request arrives.

## Profiling the pre-JS phase

1. Launch the app on the simulator with Metro already warm (a cold-Metro run produces misleading "connection refused" artifacts — discard those runs).
2. Capture the process-scoped unified log and read it as a timeline:
   `xcrun simctl spawn <udid> log show --last 5m --style compact --predicate 'process == "<AppName>"'`
3. Anchor events (see `references/ios-simctl-log-launch-markers.md` for the full set):
   - `Successfully spawned <AppName>` (from launchd_sim, NOT process-scoped — drop the predicate for this one)
   - `[FirebaseAnalytics] ... started` — marks end of dyld/runtime init
   - `-[NWConcrete_nw_browser ... create with <nw_browse_descriptor bonjour _expo._tcp...>` — Bonjour discovery starts
   - `nw_resolver_start_query_timer_block_invoke ... did not receive all answers in time` — an mDNS timeout paid somewhere
   - `(React) [RCTMultipartDataTask] GET http://127.0.0.1:<port>/index.bundle` — bundle request finally fires; everything before this is the pre-JS window
   - `Task <...> summary for task success {...}` lines carry `response_start_ms` — server-side latency of each request, useful for separating client delay from server delay.

Gotchas: `log show` timestamps are in the HOST Mac's system timezone (Asia/Kathmandu = UTC+5:45 here), not UTC; convert windows accordingly. `--start/--end` silently rejects millisecond suffixes — seconds only.

## Patching a native dependency (bun)

`bun patch <pkg>` errors out in workspaces/monorepos (`error overwriting folder in node_modules: ENOENT`, oven-sh/bun#12103). Workaround: hand-author the patch.

1. Locate the real installed package: pods resolve through `node_modules/.bun/<pkg>@<ver>+<hash>/node_modules/<pkg>` — confirm which hash the Podfile.lock actually points at before editing.
2. Copy the target files into `.tmp/<name>/orig/` and `.tmp/<name>/mod/`, edit only the `mod/` copies.
3. Generate the diff with `git diff --no-index --src-prefix=a/ --dst-prefix=b/ orig mod`, then rewrite header paths to be package-root-relative (`a/orig/ios/...` → `a/ios/...`) so it applies inside the package.
4. Register it in root `package.json` → `patchedDependencies` (match the existing entry format) and run `bun install`; verify the fix landed in the installed copy before building.
5. Rebuild native (`xcodebuild -workspace ... -scheme <Scheme> build`) — a JS-level install does NOT rebuild pods; verify with a real simulator launch, not just a successful build.

## Verified lesson from #444 (rayu.ai)

The deep-link/initial-URL launch path bypasses the SwiftUI ViewModel entirely — it goes through `EXDevLauncherController.start:launchOptions:` directly. Guards added inside the ViewModel never ran on that path. Before adding a guard, trace the actual runtime call path in the log timestamps; source-reading alone suggested the wrong entry point. Log markers and expo-dev-launcher internals: see `references/ios-simctl-log-launch-markers.md`.
