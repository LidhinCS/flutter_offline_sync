# offline_sync_flutter

Flutter adapters for push sync: Workmanager, connectivity trigger, startup recovery. Re-exports **offline_sync_core**.

## Install

```yaml
offline_sync_flutter:
  git:
    url: https://github.com/LidhinCS/flutter_offline_sync.git
    ref: main
    path: packages/offline_sync_flutter
```

## Key exports

| Export | Purpose |
| --- | --- |
| `runBackgroundSync` | One sync pass in Workmanager |
| `initBackgroundSync` / `cancelBackgroundSync` | Periodic task lifecycle |
| `FlutterSyncCoordinator` | Foreground connectivity sync |
| `ConnectivitySyncTrigger` | Manual wiring |

Plus all `offline_sync_core` exports.

## Guides

- [Push](/guide/push)
- [Foreground & background](/guide/foreground-background)

## Example

```bash
cd packages/offline_sync_flutter/example && flutter run
```

See `example/lib/background_sync.dart`.
