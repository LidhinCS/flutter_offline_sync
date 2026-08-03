# offline_sync_ui

Flutter UI widgets for [offline_sync_core](../offline_sync_core). Watches Drift
job streams and shows sync status per screen or feature.

## Quick start

```dart
import 'package:offline_sync_ui/offline_sync_ui.dart';

OfflineSyncScope(
  db: db,
  engine: engine,
  child: MaterialApp(
    home: CreatePostScreen(),
  ),
);

class CreatePostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create post'),
        actions: [
          SyncStatusBadge(
            db: OfflineSyncScope.of(context).db,
            screen: 'create_post_screen',
          ),
        ],
      ),
      body: Column(
        children: [
          SyncScreenBanner(screen: 'create_post_screen'),
          // ... rest of screen
        ],
      ),
    );
  }
}
```

When enqueueing jobs, set `meta` so list tiles can show a label:

```dart
await JobBuilder(
  db,
  feature: 'posts',
  screen: 'create_post_screen',
  meta: {'label': 'Upload photo'},
)
  .addStep('uploadImage', taskType: 'uploadImage', input: {'filePath': path})
  .enqueue();
```

## Widgets

| Widget | Purpose |
|---|---|
| `OfflineSyncScope` | Provides `SyncDatabase` + `SyncEngine` to descendants |
| `SyncJobsBuilder` | Rebuilds on `watchJobsForScreen` / `watchJobsForFeature` |
| `SyncStatusBadge` | Compact chip: "2 pending", "1 failed", etc. |
| `SyncScreenBanner` | Screen-level banner with job list + discard pending |
| `SyncJobListTile` | Single job row with retry for failed jobs |

## Helpers

- `countJobs` — group jobs by status
- `activeJobs` — filter out success/cancelled
- `jobDisplayLabel` — read `meta.label` for display
- `jobStatusAppearance` — icon/color per `JobStatus`

This package re-exports `offline_sync_core`.

## Conflict resolution

`SyncJobListTile` exposes `onConflictTap` for conflicted jobs. Wire it to your
app's resolution UI, then call `engine.resolveConflict(...)`.

## Example

```bash
cd packages/offline_sync_ui/example
flutter run
```

The example app demonstrates `OfflineSyncScope`, `SyncStatusBadge`,
`SyncScreenBanner`, and `SyncJobListTile` wired to live Drift streams.
