# offline_sync

<p align="center">
  <img src="docs/public/hero.png" alt="Flutter offline sync — phone, local database, and offline indicator" width="420" />
</p>

Offline-first sync for Flutter/Dart: **push** write queue, **pull** coordinator, Flutter adapters, and optional UI widgets.

📖 **[Documentation](https://lidhin.github.io/flutter_offline_sync/)** · [GitHub](https://github.com/LidhinCS/flutter_offline_sync) · [Changelog](https://lidhin.github.io/flutter_offline_sync/changelog)

## Packages

| Package | Role | pub.dev |
| --- | --- | --- |
| [`flutter_offline_sync_core`](packages/flutter_offline_sync_core) | Write queue — jobs, steps, `SyncEngine` | [![pub](https://img.shields.io/pub/v/flutter_offline_sync_core.svg)](https://pub.dev/packages/flutter_offline_sync_core) |
| [`flutter_offline_sync_push`](packages/flutter_offline_sync_push) | Workmanager + connectivity for push | [![pub](https://img.shields.io/pub/v/flutter_offline_sync_push.svg)](https://pub.dev/packages/flutter_offline_sync_push) |
| [`flutter_offline_sync_pull`](packages/flutter_offline_sync_pull) | Pull coordinator — lists, batches, checkpoints | [![pub](https://img.shields.io/pub/v/flutter_offline_sync_pull.svg)](https://pub.dev/packages/flutter_offline_sync_pull) |
| [`flutter_offline_sync_pull_flutter`](packages/flutter_offline_sync_pull_flutter) | Workmanager + connectivity for pull | [![pub](https://img.shields.io/pub/v/flutter_offline_sync_pull_flutter.svg)](https://pub.dev/packages/flutter_offline_sync_pull_flutter) |
| [`flutter_offline_sync_ui`](packages/flutter_offline_sync_ui) | Sync job status widgets | [![pub](https://img.shields.io/pub/v/flutter_offline_sync_ui.svg)](https://pub.dev/packages/flutter_offline_sync_ui) |

## Install

```yaml
dependencies:
  flutter_offline_sync_push: ^0.1.0
  flutter_offline_sync_pull_flutter: ^0.1.0
  flutter_offline_sync_ui: ^0.1.0 # optional
```

`flutter_offline_sync_push` and `flutter_offline_sync_pull_flutter` re-export their core packages.

See the [installation guide](https://lidhin.github.io/flutter_offline_sync/guide/installation) for details.

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
cd packages/flutter_offline_sync_core/example && flutter run
cd packages/flutter_offline_sync_push/example && flutter run
cd packages/flutter_offline_sync_pull/example && flutter run
cd packages/flutter_offline_sync_pull_flutter/example && flutter run
cd packages/flutter_offline_sync_ui/example && flutter run
```

## Codegen

```bash
dart run melos run build_runner
```

## License

MIT — see [LICENSE](LICENSE).
