# Troubleshooting

## `getIt` / Injectable not found in Workmanager

**Cause:** Background isolate does not run `configureDependencies()`.

**Fix:** Rebuild `SyncEngine`, `PullCoordinator`, Dio, and registries in top-level factories. Never call `getIt` in `callbackDispatcher`.

## `melos: command not found` when running scripts

**Cause:** Nested `melos exec` with `dart run melos` on some setups.

**Fix:** Use root shell scripts in `pubspec.yaml` melos config or run package commands directly.

## Drift: multiple databases warning in tests

**Cause:** Multiple `PullDatabase` / `SyncDatabase` on same in-memory executor.

**Fix:** One DB per test, unique `NativeDatabase.memory()`, close in `tearDown`.

## Background sync never runs

- Check Workmanager init and `callbackDispatcher` registered
- iOS: background fetch is best-effort
- Android: battery optimization / force-stop blocks tasks
- Verify `registerPeriodicTask` constraints (`NetworkType.connected`)

## Token null in background

- Device locked with restrictive Keychain accessibility
- User logged out — skip sync, return `true` from task
- Read secure storage again in background; do not use in-memory token

## Pull list empty but checkpoint advances

Handlers must upsert into **AppDatabase**. Checkpoint only tracks pull progress.

## `resolution: workspace` in monorepo packages

External apps consuming via Git `path:` should not use workspace resolution. Published pub.dev packages will use normal path/version deps.

## Handler not found

Register handler in **both**:

1. Foreground `buildRegistry` / `buildPullRegistry` (DI)
2. Background factory (same builder function)

## Still stuck?

Open an issue with: platform, foreground vs background, package versions, and whether push or pull path fails.
