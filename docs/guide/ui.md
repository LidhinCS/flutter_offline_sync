# UI widgets

`offline_sync_ui` provides widgets that watch **sync job** streams from `SyncDatabase` — not pull checkpoints.

## Setup

```dart
import 'package:offline_sync_ui/offline_sync_ui.dart';

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

Scope jobs by `screen` when enqueueing:

```dart
await JobBuilder(
  db,
  feature: 'posts',
  screen: 'create_post_screen',
  meta: {'label': 'Upload photo'},
)
```

`meta.label` improves list tile text.

## Pull UI

Pull progress is usually reflected in **App DB** (new rows). Optional future: pull status widgets. Today use repository streams for list content and manual refresh or coordinator triggers for pull state.

## Package

[offline_sync_ui](/packages/offline_sync_ui) · example: `packages/offline_sync_ui/example`
