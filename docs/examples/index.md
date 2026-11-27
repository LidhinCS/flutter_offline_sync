# Examples

## Full-stack app (start here)

The **Offline Notes** app under [`examples/notes_app`](https://github.com/LidhinCS/flutter_offline_sync/tree/main/examples/notes_app) is the primary teaching example. It wires push, pull, Flutter coordinators, UI widgets, and a real Drift **AppDatabase** in clean-architecture folders.

For a minimal enqueue + `syncAll` walkthrough in docs only, see [Quick Start](/guide/quick-start).

```bash
cd examples/notes_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

What it demonstrates:

- Optimistic create → `JobBuilder` enqueue (1-step or upload-then-create)
- `SyncEngine.syncAll` + `PullCoordinator.runAll` (push-then-pull reconnect)
- `FlutterSyncCoordinator` / `FlutterPullCoordinator`
- `OfflineSyncScope`, badges, banners, job tiles, activity indicator
- Three databases: App / Sync / Pull

See the app’s README and in-app **Guide** tab.

## Per-package examples

Each package also includes a focused Flutter example under `packages/<name>/example`.

| Example | Path | Demonstrates |
| --- | --- | --- |
| Core push | `packages/flutter_offline_sync_core/example` | Handlers, enqueue, `syncAll()` |
| Flutter push | `packages/flutter_offline_sync_push/example` | `FlutterSyncCoordinator`, Workmanager |
| Pull core | `packages/flutter_offline_sync_pull/example` | Paginated + entity-batch pulls |
| Pull Flutter | `packages/flutter_offline_sync_pull_flutter/example` | Connectivity + background pull |
| UI | `packages/flutter_offline_sync_ui/example` | Badges, banners, list tiles |

```bash
dart pub get

cd packages/flutter_offline_sync_core/example && flutter run
cd packages/flutter_offline_sync_push/example && flutter run
cd packages/flutter_offline_sync_pull/example && flutter run
cd packages/flutter_offline_sync_pull_flutter/example && flutter run
cd packages/flutter_offline_sync_ui/example && flutter run
```

## Full integration recipe

1. Add `flutter_offline_sync_push` + `flutter_offline_sync_pull_flutter` to app `pubspec`.
2. Implement `buildRegistry(dio)` and `buildPullRegistry(dio, localDatasources…)`.
3. Register modules or a manual composition root (see `examples/notes_app`).
4. `bootstrap`: `setupBackgroundSync`, start both `Flutter*Coordinator`s.
5. On reconnect: `syncAll()` then `runAll()`.
6. Optional: `flutter_offline_sync_ui` + `OfflineSyncScope`.

See [Clean architecture](/guide/clean-architecture) and [Architecture](/guide/architecture).

## Fake data in examples

Examples use in-memory or fake handlers — not production APIs. In your app, handlers call Dio and upsert into **AppDatabase**.
