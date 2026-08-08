# offline_sync_core

Dart-only write queue: jobs, steps, `SyncEngine`, Drift outbox.

## When to use

- Unit/integration tests without Flutter
- Custom foreground-only apps (no Workmanager)
- Understanding push internals

Flutter apps usually depend on [offline_sync_flutter](/packages/offline_sync_flutter) instead.

## Install

```yaml
offline_sync_core:
  git:
    url: https://github.com/LidhinCS/flutter_offline_sync.git
    ref: main
    path: packages/offline_sync_core
```

## Key exports

- `SyncDatabase`, `SyncEngine`, `JobBuilder`
- `SyncTaskHandler`, `SyncHandlerRegistry`
- `SyncContext`, `SyncStepResult`

## Guide

[Push (write queue)](/guide/push)

## Example

```bash
cd packages/offline_sync_core/example && flutter run
```

## API reference

Dartdoc on pub.dev when published — search `offline_sync_core`.
