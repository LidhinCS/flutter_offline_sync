# Foreground & background

How sync runs while the app is open versus in a Workmanager isolate.

## Foreground

```dart
import 'package:flutter_offline_sync_push/flutter_offline_sync_push.dart';
import 'package:flutter_offline_sync_pull_flutter/flutter_offline_sync_pull_flutter.dart';

// You already built these at startup:
late final SyncEngine engine;
late final PullCoordinator pull;

final pushCoordinator = FlutterSyncCoordinator(engine: engine);
await pushCoordinator.startForegroundSync();
// Recovers interrupted push work, listens for connectivity, runs syncAll().

final flutterPullCoordinator = FlutterPullCoordinator(coordinator: pull);
await flutterPullCoordinator.startForegroundPull();
// Listens for connectivity and runs pull.runAll() when online.
```

::: warning
`FlutterPullCoordinator` takes your **`PullCoordinator`** instance (`coordinator:`). Do not pass the Flutter wrapper into its own constructor.
:::

Initialize Workmanager once at startup (push example; pull has `initBackgroundPull` with the same shape):

```dart
await initBackgroundSync(
  callbackDispatcher: callbackDispatcher,
  uniqueName: 'com.yourapp.sync',
  registerPeriodicTask: true, // or false for manual-only demos
);
```

If you use **both** push and pull in one process, prefer a **single** Workmanager `initialize` + one dispatcher that runs both (see below). Calling `initBackgroundSync` and `initBackgroundPull` separately both call `Workmanager().initialize`.

## Background entrypoint

Must be **top-level** with `@pragma('vm:entry-point')`:

```dart
import 'package:workmanager/workmanager.dart';
import 'package:flutter_offline_sync_push/flutter_offline_sync_push.dart';
import 'package:flutter_offline_sync_pull_flutter/flutter_offline_sync_pull_flutter.dart';

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
  final db = SyncDatabase(); // same default path as foreground
  return SyncEngine(db: db, registry: buildRegistry(dio));
}

@pragma('vm:entry-point')
Future<PullCoordinator> createBackgroundPullCoordinator() async {
  final dio = await createBackgroundDio();
  final appDb = AppDatabase(); // your DB, same path as foreground
  final local = NotesLocalDatasource(appDb); // your type
  final pullDb = PullDatabase();
  return PullCoordinator(
    db: pullDb,
    registry: buildPullRegistry(dio, local),
  );
}
```

## Isolate rules

| Do | Don't |
| --- | --- |
| Re-open `SyncDatabase` / `PullDatabase` (and App DB if handlers need it) | `getIt<SyncEngine>()` in Workmanager |
| Re-register all handlers via shared `buildRegistry` functions | Pass a foreground `Dio` instance across isolates |
| Read tokens from secure storage again | Assume Injectable singletons exist |
| Return `true` from the task when skipping (e.g. logged out) | Show login UI from the background isolate |

## WAL mode

`SyncDatabase` enables WAL so foreground and background can hold separate connections to the same file safely. Mirror WAL + `busy_timeout` on your App DB if both isolates touch it — [Drift & App database](/guide/drift).

## Platform limits

- Android periodic Workmanager: minimum interval is typically ~15 minutes
- iOS `BGTaskScheduler`: best-effort, no guaranteed interval

Use connectivity triggers for low latency while the app is open.

See [Authentication](/guide/authentication) for tokens in background.
