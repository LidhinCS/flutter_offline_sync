# flutter_offline_sync_pull_flutter

[![pub package](https://img.shields.io/pub/v/flutter_offline_sync_pull_flutter.svg)](https://pub.dev/packages/flutter_offline_sync_pull_flutter)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Flutter adapters for [flutter_offline_sync_pull](https://pub.dev/packages/flutter_offline_sync_pull): Workmanager
background pull and connectivity-triggered foreground pull.

**Docs:** [Foreground & background](https://lidhin.github.io/flutter_offline_sync/guide/foreground-background) ·
[GitHub](https://github.com/LidhinCS/flutter_offline_sync)

## Install

```yaml
dependencies:
  flutter_offline_sync_pull_flutter: ^0.1.0
```

Pair with [flutter_offline_sync_push](https://pub.dev/packages/flutter_offline_sync_push) for full offline-first:

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

Re-exports `flutter_offline_sync_pull`.

## Example

```bash
cd packages/flutter_offline_sync_pull_flutter/example
flutter run
```
