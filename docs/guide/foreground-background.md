# Foreground & background

## Foreground

```dart
final coordinator = FlutterSyncCoordinator(engine: engine);
await coordinator.startForegroundSync();

final pullCoordinator = FlutterPullCoordinator(coordinator: pullCoordinator);
await pullCoordinator.startForegroundPull();
```

This:

1. Recovers jobs/steps stuck in `running` after a kill (push)
2. Listens for connectivity and runs `syncAll()` / `runAll()` when online

Initialize Workmanager once at startup:

```dart
await initBackgroundSync(
  callbackDispatcher: callbackDispatcher,
  uniqueName: 'com.yourapp.sync',
  registerPeriodicTask: true, // or false for manual-only
);
```

## Background entrypoint

Must be **top-level** with `@pragma('vm:entry-point')`:

```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await runBackgroundSync(createBackgroundSyncEngine);
    await runBackgroundPull(createBackgroundPullCoordinator);
    return true;
  });
}
```

Factories must be top-level or static — **no closures** crossing isolates.

```dart
@pragma('vm:entry-point')
Future<SyncEngine> createBackgroundSyncEngine() async {
  final dio = await createBackgroundDio(); // read tokens, build client
  final db = SyncDatabase(); // same path as foreground
  return SyncEngine(db: db, registry: buildRegistry(dio));
}
```

## Isolate rules

| Do | Don't |
| --- | --- |
| `WidgetsFlutterBinding.ensureInitialized()` in background | `getIt<SyncEngine>()` in Workmanager |
| Re-open `SyncDatabase` / `PullDatabase` | Pass foreground `Dio` instance |
| Re-register all handlers | Assume Injectable singletons exist |
| Share `buildRegistry` / `buildPullRegistry` functions | Duplicate divergent handler logic |

## WAL mode

`SyncDatabase` uses WAL so foreground and background can hold separate connections to the same file safely.

## Platform limits

- Android periodic Workmanager: minimum ~15 minutes
- iOS `BGTaskScheduler`: best-effort, no guaranteed interval

Use connectivity triggers for low latency while the app is open.

See [Authentication](/guide/authentication) for tokens in background.
