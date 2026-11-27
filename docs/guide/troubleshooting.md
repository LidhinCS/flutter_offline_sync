# Troubleshooting

Practical failures and fixes. Conceptual Q&A: [FAQ](/guide/faq).

## Handler not found / `StateError: No handler registered`

**Cause:** `taskType` missing from the registry in the isolate that is running sync.

**Fix:** Register the same builders in:

1. Foreground `buildRegistry` / `buildPullRegistry`
2. Background factory (shared function — do not diverge)

## `getIt` / Injectable not found in Workmanager

**Cause:** Background isolate never ran `configureDependencies()`.

**Fix:** Rebuild `SyncEngine`, `PullCoordinator`, Dio, and registries in top-level factories. Never call `getIt` in `callbackDispatcher`.

## Pull list empty but checkpoint advances

**Cause:** Handler updates checkpoints (via coordinator) but never upserts **AppDatabase**.

**Fix:** Upsert in `PullStepHandler.fetch` through your local datasource. UI must watch App DB, not checkpoints.

## Background sync never runs

- Confirm `Workmanager().initialize(callbackDispatcher)` ran once
- Confirm `@pragma('vm:entry-point')` on the dispatcher and factories
- iOS: background fetch is best-effort
- Android: battery optimization / force-stop can block tasks
- Check `registerPeriodicTask` and `Constraints(networkType: NetworkType.connected)`

## Token null / 401 in background

- Re-read secure storage in the background factory (isolates do not share memory)
- iOS: use Keychain accessibility that allows background reads ([Authentication](/guide/authentication))
- If logged out, skip sync and return `true` from the Workmanager task

## Jobs stuck in `running`

Call `engine.recoverInterruptedWork()` or start `FlutterSyncCoordinator` (it recovers on startup). `syncAll` also recovers interrupted work at the beginning of a pass.

## Conflict never clears

Returning `.failure` on a 409 will not pause for UI resolution. Return `SyncStepResult.conflict(...)`, then `engine.resolveConflict(jobId, stepKey, resolution)`.

## Drift: multiple databases warning in tests

**Cause:** Multiple package DB instances on the same in-memory executor.

**Fix:** One DB per test, unique `NativeDatabase.memory()` / `forTesting`, close in `tearDown`.

## `melos: command not found` when running contributor scripts

**Cause:** Nested melos invocation quirks on some setups.

**Fix:** Use root scripts in `pubspec.yaml` melos config or run package commands directly (`dart analyze`, `flutter test`).

## `resolution: workspace` in package pubspecs

Apps consuming via Git `path:` should not rely on Melos workspace resolution. Published pub.dev packages use normal version constraints.

## Self-referencing pull coordinator (copy/paste bug)

Wrong:

```dart
final pullCoordinator = FlutterPullCoordinator(coordinator: pullCoordinator);
```

Right:

```dart
final pull = PullCoordinator(db: pullDb, registry: registry);
final flutterPull = FlutterPullCoordinator(coordinator: pull);
```

## Still stuck?

Open an issue with: platform, foreground vs background, package versions, and whether the push or pull path fails.
