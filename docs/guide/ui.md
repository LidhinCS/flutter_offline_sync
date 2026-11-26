# UI widgets

`flutter_offline_sync_ui` provides widgets that watch **sync job** streams from `SyncDatabase`, plus an activity chip driven by push/pull busy streams.

## Setup

```dart
import 'package:flutter_offline_sync_ui/flutter_offline_sync_ui.dart';

OfflineSyncScope(
  db: syncDb,
  engine: engine,
  child: MaterialApp(/* ... */),
);
```

## Widgets

| Widget | Purpose |
| --- | --- |
| `SyncStatusBadge` | Compact status in app bar |
| `SyncScreenBanner` | Banner for a `screen` key |
| `SyncJobListTile` | Row per job with retry |
| `SyncJobsBuilder` | Build list from job stream |
| `SyncActivityIndicator` | Busy chip while push/pull runs |

Scope jobs by `screen` when enqueueing:

```dart
await JobBuilder(
  db,
  feature: 'posts',
  screen: 'create_post_screen',
  meta: {
    'label': 'Upload photo',
    'subtitle': 'Site report · doc-123',
  },
)
```

`meta.label` / `meta.subtitle` improve list tile text.

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

Pass `db` + `feature`/`screen` so background Workmanager jobs marked `running` also light the chip. Localized strings stay in the host app.

## History

Use `historyJobs` for recent success/cancelled rows. Call `SyncDatabase.pruneCompletedJobs` periodically to bound storage.

## Package

[flutter_offline_sync_ui](/packages/flutter_offline_sync_ui) · example: `packages/flutter_offline_sync_ui/example`
