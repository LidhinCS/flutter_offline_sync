# offline_sync

Offline-first sync for Flutter/Dart: **push** write queue, **pull** coordinator, Flutter adapters, and optional UI widgets.

📖 **[Documentation](https://lidhin.github.io/flutter_offline_sync/)** · [GitHub](https://github.com/LidhinCS/flutter_offline_sync)


## Packages

| Package | Role |
| --- | --- |
| `offline_sync_core` | Write queue — jobs, steps, `SyncEngine` |
| `offline_sync_flutter` | Workmanager + connectivity for push |
| `offline_sync_pull` | Pull coordinator — lists, batches, checkpoints |
| `offline_sync_pull_flutter` | Workmanager + connectivity for pull |
| `offline_sync_ui` | Sync job status widgets |

## Quick install

```yaml
dependencies:
  offline_sync_flutter:
    git:
      url: https://github.com/LidhinCS/flutter_offline_sync.git
      ref: main
      path: packages/offline_sync_flutter
```

See the [installation guide](https://lidhin.github.io/flutter_offline_sync/guide/installation) for pull, UI, and pub.dev snippets.

## Development

```bash
dart pub get
dart run melos run test
dart run melos run analyze
```

## Documentation site (local)

```bash
cd docs && npm install && npm run dev
```

## Examples

```bash
cd packages/offline_sync_core/example && flutter run
cd packages/offline_sync_flutter/example && flutter run
cd packages/offline_sync_pull/example && flutter run
cd packages/offline_sync_pull_flutter/example && flutter run
cd packages/offline_sync_ui/example && flutter run
```

## Codegen

```bash
dart run melos run build_runner
```
