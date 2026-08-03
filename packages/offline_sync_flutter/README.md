# offline_sync_flutter

Flutter adapters for [offline_sync_core](../offline_sync_core): Workmanager
background sync, connectivity-triggered foreground sync, and startup recovery.

`offline_sync_core` stays plain Dart and unit-testable without Flutter. This
package owns everything that needs `flutter`, `workmanager`, or
`connectivity_plus`.

## Quick start

```dart
import 'package:dio/dio.dart';
import 'package:offline_sync_flutter/offline_sync_flutter.dart';

const _syncTaskName = 'com.example.app.syncTask';

// 1. Register handlers and create the engine (foreground).
final registry = SyncHandlerRegistry()
  ..register('uploadImage', UploadImageHandler(dio));
final db = SyncDatabase();
final engine = SyncEngine(db: db, registry: registry);

// 2. Foreground: recover + sync when connectivity returns.
final coordinator = FlutterSyncCoordinator(engine: engine);
await coordinator.startForegroundSync();

// 3. Background: top-level entrypoint required by Workmanager.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    return runBackgroundSync(createBackgroundSyncEngine);
  });
}

@pragma('vm:entry-point')
Future<SyncEngine> createBackgroundSyncEngine() async {
  final db = SyncDatabase(); // same sqlite path as foreground
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  return SyncEngine(db: db, registry: buildRegistry(dio));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initBackgroundSync(
    callbackDispatcher: callbackDispatcher,
    uniqueName: _syncTaskName,
  );
  // ... rest of app startup
}
```

## API

| Export | Purpose |
|---|---|
| `runBackgroundSync` | Single background sync pass inside a Workmanager task |
| `initBackgroundSync` | Initialize Workmanager + register periodic task |
| `cancelBackgroundSync` | Cancel a periodic task by name |
| `ConnectivitySyncTrigger` | Call `engine.syncAll()` when connectivity returns |
| `FlutterSyncCoordinator` | Startup recovery + connectivity trigger in one call |

This package re-exports `offline_sync_core`, so a single import covers both
the engine and the Flutter glue.

## Background isolate constraints

The Workmanager callback runs in a separate OS-spawned isolate with no shared
memory. You must:

1. Call `WidgetsFlutterBinding.ensureInitialized()` (handled by `runBackgroundSync`)
2. Re-open `SyncDatabase` at the same file path
3. Re-register every handler in a new `SyncHandlerRegistry`

`createEngine` passed to `runBackgroundSync` must be a **top-level or static**
function — closures cannot cross isolate boundaries.

## Periodic background sync limits

- Android: minimum interval is 15 minutes
- iOS: `BGTaskScheduler` is best-effort with no guaranteed interval

Use `ConnectivitySyncTrigger` / `FlutterSyncCoordinator` for low-latency sync
while the app is in the foreground.

## Example

```bash
cd packages/offline_sync_flutter/example
flutter run
```

See `example/lib/background_sync.dart` for Workmanager wiring and
`example/lib/main.dart` for `FlutterSyncCoordinator` usage.
