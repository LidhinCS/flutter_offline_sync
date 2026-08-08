# offline_sync_pull_flutter

Flutter adapters for pull: Workmanager + `FlutterPullCoordinator`. Re-exports **offline_sync_pull**.

## Install

```yaml
offline_sync_pull_flutter:
  git:
    url: https://github.com/LidhinCS/flutter_offline_sync.git
    ref: main
    path: packages/offline_sync_pull_flutter
```

## Key exports

| Export | Purpose |
| --- | --- |
| `runBackgroundPull` | One pull pass in Workmanager |
| `initBackgroundPull` / `cancelBackgroundPull` | Periodic pull task |
| `FlutterPullCoordinator` | Foreground connectivity pull |
| `ConnectivityPullTrigger` | Manual wiring |

## Guides

- [Pull](/guide/pull)
- [Foreground & background](/guide/foreground-background)

## Example

```bash
cd packages/offline_sync_pull_flutter/example && flutter run
```
