# iOS simulator `log show` markers for launch profiling

Anchor events, in expected chronological order, from the rayu.ai #444 investigation (expo-dev-client 57, RN new arch). Process name = app target name; bundle id differs per env (`ai.rayu.app.stg` for staging).

## Capture commands

```bash
# process-scoped timeline
xcrun simctl spawn <udid> log show --last 5m --style compact --predicate 'process == "<AppName>"'

# spawn marker lives on launchd_sim — no predicate
xcrun simctl spawn <udid> log show --last 60s --style compact | grep "Successfully spawned <AppName>"

# deep-link launch with explicit URL (what expo start / xcode uses)
xcrun simctl launch <udid> <bundle-id> --args --initialUrl "<scheme>://expo-development-client/?url=http%3A%2F%2F127.0.0.1%3A<port>"
```

## Markers

| Event | Log line fragment | Meaning |
|---|---|---|
| Spawn | `Successfully spawned <AppName>[<pid>]` | T+0. From `launchd_sim`, so run without the process predicate. |
| Runtime init ends | `[FirebaseAnalytics] ... Analytics v.xx started` / Crashlytics handler install | Firebase burst completes within ~6ms of itself; end of dyld/module registration. |
| Bonjour browse starts | `-[NWConcrete_nw_browser initWithDescriptor:parameters:] [B1] create with <nw_browse_descriptor bonjour _expo._tcp` | Dev-launcher server discovery begins. |
| mDNS timeout paid | `nw_resolver_start_query_timer_block_invoke [C2.1.1] Query fired: did not receive all answers in time` | ~2s cost. NOTE (#444 finding): this can fire AFTER the connection already resolved+cancelled — check whether the connection is still open before treating it as critical-path time. |
| Bundle request fires | `(React) [RCTMultipartDataTask] GET http://127.0.0.1:<port>/index.bundle...` | Pre-JS window ends here. |
| Per-request latency | `Task <uuid>.<n> summary for task success {...}` | Fields: `response_start_ms` (server think-time), `transaction_duration_ms` (total), `request_start_ms`. |

## Gotchas learned the hard way

- Timestamps display in host-local timezone (Kathmandu UTC+5:45), regardless of `date -u` output.
- `log show --start/--end` rejects milliseconds (`.123`) silently — use whole seconds.
- A cold Metro restart produces a misleading "Connection refused" window; always profile with Metro warm.
- Corroborate client-side timings by curling the same endpoint: Expo CLI's bare `HEAD /` answered in ~0.7–0.9s from curl and ~1.9s server-side inside the app — real cost that looks like an app-side stall if you only read app logs.

## expo-dev-launcher internals quick map (v57)

- `ios/EXDevLauncherController.m`
  - `start:launchOptions:` — entry from `ExpoDevLauncherReactDelegateHandler.createReactRootView`. Handles embedded-bundle short-circuit, then `initialUrlFromProcessInfo` → `loadApp:` directly (bypasses all SwiftUI).
  - `onDeepLink:` → warm deep links.
  - `loadApp:withProjectUrl:withTimeout:onSuccess:onError:` — parses URL type via `EXDevLauncherManifestParser`; non-manifest URLs take the direct `launchReactNativeApp()` fast path; manifest-looking URLs go through `_updatesInterface`.
- `ios/Manifest/EXDevLauncherManifestParser.m`
  - `isManifestURLWithCompletion:` sends `HEAD` to the URL. Classification bug fixed in our patch: `application/expo+json` was falling into the published-manifest branch.
- `ios/SwiftUI/DevLauncherViewModel.swift`
  - `startServerDiscovery()` creates the `_expo._tcp` NWBrowser; `openApp(url:)` is only used by taps INSIDE the launcher UI, not the initial-URL path.
  - `checkLocalNetworkAccess()` spins its own temporary NWBrowser/NWListener with a 2s cap — a separate browse source to keep straight when reading traces.
- `ios/SwiftUI/NetworkUtilities.swift` — `resolveBundlerEndpoint` (7s outer timeout), `connectionStart` (3s); the observed ~2s mDNS cost was the OS resolver's internal timer, not these constants.
- Pod source location under bun: `node_modules/.bun/expo-dev-launcher@<ver>+<hash>/node_modules/expo-dev-launcher` — confirm the hash against `Podfile.lock`'s `:path:` before patching.
