# offline_sync_pull_flutter

Flutter adapters for [offline_sync_pull](https://github.com/LidhinCS/flutter_offline_sync/tree/main/packages/offline_sync_pull): Workmanager
background pull and connectivity-triggered foreground pull.

Pair with [offline_sync_flutter](https://github.com/LidhinCS/flutter_offline_sync/tree/main/packages/offline_sync_flutter) for full offline-first:

```dart
// Foreground
await pushCoordinator.startForegroundSync();
await pullCoordinator.startForegroundPull();

// Background Workmanager callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await runBackgroundSync(createBackgroundSyncEngine);  // push
    await runBackgroundPull(createPullCoordinator);       // pull
    return true;
  });
}
```

## API

| Export | Purpose |
|---|---|
| `runBackgroundPull` | One pull pass inside a Workmanager task |
| `initBackgroundPull` | Initialize Workmanager + periodic pull |
| `cancelBackgroundPull` | Cancel periodic task |
| `ConnectivityPullTrigger` | `coordinator.runAll()` when online |
| `FlutterPullCoordinator` | Start/stop connectivity pull listener |

Re-exports `offline_sync_pull`.

## Example

```bash
cd packages/offline_sync_pull_flutter/example
flutter run
```
