# Packages

Five packages — pick adapters for Flutter apps; use core packages alone for Dart-only tests.

| Package | Dart/Flutter | Role |
| --- | --- | --- |
| [flutter_offline_sync_core](/packages/flutter_offline_sync_core) | Dart | Push engine |
| [flutter_offline_sync_push](/packages/flutter_offline_sync_push) | Flutter | Push + re-exports core |
| [flutter_offline_sync_pull](/packages/flutter_offline_sync_pull) | Dart | Pull coordinator |
| [flutter_offline_sync_pull_flutter](/packages/flutter_offline_sync_pull_flutter) | Flutter | Pull + re-exports pull |
| [flutter_offline_sync_ui](/packages/flutter_offline_sync_ui) | Flutter | Job status widgets |

Typical app dependencies:

```yaml
dependencies:
  flutter_offline_sync_push: ^0.1.2
  flutter_offline_sync_pull_flutter: ^0.1.2
  flutter_offline_sync_ui: ^0.1.2 # optional
```

See [Installation](/guide/installation) for Git alternatives and package choice.
