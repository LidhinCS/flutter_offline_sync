# Examples

Each package includes a runnable Flutter example under `packages/<name>/example`.

| Example | Path | Demonstrates |
| --- | --- | --- |
| Core push | `packages/offline_sync_core/example` | Handlers, enqueue, `syncAll()` |
| Flutter push | `packages/offline_sync_flutter/example` | `FlutterSyncCoordinator`, Workmanager |
| Pull core | `packages/offline_sync_pull/example` | Paginated + entity-batch pulls |
| Pull Flutter | `packages/offline_sync_pull_flutter/example` | Connectivity + background pull |
| UI | `packages/offline_sync_ui/example` | Badges, banners, list tiles |

## Run from monorepo root

```bash
dart pub get

cd packages/offline_sync_core/example && flutter run
cd packages/offline_sync_flutter/example && flutter run
cd packages/offline_sync_pull/example && flutter run
cd packages/offline_sync_pull_flutter/example && flutter run
cd packages/offline_sync_ui/example && flutter run
```

## Full integration recipe

1. Add `offline_sync_flutter` + `offline_sync_pull_flutter` to app `pubspec`.
2. Implement `buildRegistry(dio)` and `buildPullRegistry(dio, localDatasources…)`.
3. Register `SyncModule` / `PullModule` (Injectable) or manual GetIt.
4. `bootstrap`: `setupBackgroundSync`, start both `Flutter*Coordinator`s.
5. On reconnect: `syncAll()` then `runAll()`.
6. Optional: `offline_sync_ui` + `OfflineSyncScope`.

See [Clean architecture](/guide/clean-architecture) and [Architecture](/guide/architecture).

## Fake data in examples

Examples use in-memory or fake handlers — not production APIs. In your app, handlers call Dio and upsert into **AppDatabase**.
