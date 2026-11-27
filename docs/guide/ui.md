# UI widgets

`flutter_offline_sync_ui` provides widgets that watch **sync job** streams from `SyncDatabase`, plus an activity chip driven by push/pull busy streams.

## What this integration accomplishes

Show pending / failed / conflicted outbox work without writing your own Drift queries for SyncDatabase.

Optional — skip this package if you build custom sync UI.

## Setup

```dart
import 'package:flutter_offline_sync_ui/flutter_offline_sync_ui.dart';

OfflineSyncScope(
  db: syncDb,
  engine: engine,
  child: MaterialApp(/* ... */),
);
```

`OfflineSyncScope.of(context)` exposes `db` and `engine` to descendants.

## Widgets

| Widget | Purpose |
| --- | --- |
| `SyncStatusBadge` | Compact status in app bar (`screen` or `feature`) |
| `SyncScreenBanner` | Banner for a `screen` key (uses scope if `db`/`engine` omitted) |
| `SyncJobListTile` | Row per job with retry |
| `SyncJobsBuilder` | Build UI from job stream |
| `SyncActivityIndicator` | Busy chip while push/pull runs |

Scope jobs when enqueueing:

```dart
await JobBuilder(
  syncDb,
  feature: 'posts',
  screen: 'create_post_screen',
  meta: {
    'label': 'Upload photo',
    'subtitle': 'Site report · doc-123',
  },
)
    .addStep(
      'uploadImage',
      taskType: 'uploadImage',
      input: {'filePath': path},
    )
    .enqueue();
```

`meta.label` / `meta.subtitle` improve list tile text via helpers in the UI package.

## Sync activity

```dart
SyncActivityIndicator(
  isPushing: engine.isSyncingStream,
  isPulling: pullCoordinator.isPullingStream,
  initialPushing: engine.isSyncing,
  initialPulling: pullCoordinator.isPulling,
  db: syncDb,
  feature: 'documents',
);
```

Pass `db` + `feature`/`screen` so jobs marked `running` (including background Workmanager) also light the chip. Localized strings stay in the host app.

## History

Use `historyJobs` for recent success/cancelled rows. Call `SyncDatabase.pruneCompletedJobs` periodically to bound storage.

## Package

[flutter_offline_sync_ui](/packages/flutter_offline_sync_ui) · example: `packages/flutter_offline_sync_ui/example`
