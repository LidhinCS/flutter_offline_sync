# Changelog

Aggregated release notes for **0.1.1**. Per-package details live in each package’s `CHANGELOG.md` on [pub.dev](https://pub.dev).

## 0.1.1 — 2026-11-27

Pub.dev score / metadata fixes across the suite.

| Package | Version | pub.dev |
| --- | --- | --- |
| `flutter_offline_sync_core` | 0.1.1 | [flutter_offline_sync_core](https://pub.dev/packages/flutter_offline_sync_core) |
| `flutter_offline_sync_push` | 0.1.1 | [flutter_offline_sync_push](https://pub.dev/packages/flutter_offline_sync_push) |
| `flutter_offline_sync_pull` | 0.1.1 | [flutter_offline_sync_pull](https://pub.dev/packages/flutter_offline_sync_pull) |
| `flutter_offline_sync_pull_flutter` | 0.1.1 | [flutter_offline_sync_pull_flutter](https://pub.dev/packages/flutter_offline_sync_pull_flutter) |
| `flutter_offline_sync_ui` | 0.1.1 | [flutter_offline_sync_ui](https://pub.dev/packages/flutter_offline_sync_ui) |

### Highlights

- Fix homepage / documentation URLs (`lidhincs.github.io`)
- Shorten long pubspec descriptions
- Drop obsolete `sqlite3_flutter_libs`; keep `sqlite3` 3.x
- Raise Drift lower bound to `^2.35.3` for pub lower-bound analysis
- Migrate `flutter_offline_sync_ui` to `package:material_ui` (Flutter 3.47+)

## 0.1.0 — 2026-11-27

First public release of the flutter_offline_sync suite.

| Package | Version | pub.dev |
| --- | --- | --- |
| `flutter_offline_sync_core` | 0.1.0 | [flutter_offline_sync_core](https://pub.dev/packages/flutter_offline_sync_core) |
| `flutter_offline_sync_push` | 0.1.0 | [flutter_offline_sync_push](https://pub.dev/packages/flutter_offline_sync_push) |
| `flutter_offline_sync_pull` | 0.1.0 | [flutter_offline_sync_pull](https://pub.dev/packages/flutter_offline_sync_pull) |
| `flutter_offline_sync_pull_flutter` | 0.1.0 | [flutter_offline_sync_pull_flutter](https://pub.dev/packages/flutter_offline_sync_pull_flutter) |
| `flutter_offline_sync_ui` | 0.1.0 | [flutter_offline_sync_ui](https://pub.dev/packages/flutter_offline_sync_ui) |

### Highlights

- **Push**: Job/Step DAG write queue, partial retry, conflicts, auto-retry of retryable failures, `isSyncingStream`
- **Pull**: Paginated + entity-batch steps, checkpoints, `maxPagesPerRun`, `isPullingStream`
- **Flutter adapters**: Workmanager + connectivity coordinators for push and pull
- **UI**: Badges, banners, list tiles, `SyncActivityIndicator`, history helpers + `pruneCompletedJobs`
