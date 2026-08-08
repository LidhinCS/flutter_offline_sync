# Packages

Five packages — pick adapters for Flutter apps; use core packages alone for Dart-only tests.

| Package | Dart/Flutter | Role |
| --- | --- | --- |
| [offline_sync_core](/packages/offline_sync_core) | Dart | Push engine |
| [offline_sync_flutter](/packages/offline_sync_flutter) | Flutter | Push + re-exports core |
| [offline_sync_pull](/packages/offline_sync_pull) | Dart | Pull coordinator |
| [offline_sync_pull_flutter](/packages/offline_sync_pull_flutter) | Flutter | Pull + re-exports pull |
| [offline_sync_ui](/packages/offline_sync_ui) | Flutter | Job status widgets |

Typical app dependencies:

```yaml
offline_sync_flutter: ...
offline_sync_pull_flutter: ...
offline_sync_ui: ... # optional
```

See [Installation](/guide/installation) for full `pubspec` blocks.
