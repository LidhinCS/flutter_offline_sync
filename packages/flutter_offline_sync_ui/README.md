# flutter_offline_sync_ui

[![pub package](https://img.shields.io/pub/v/flutter_offline_sync_ui.svg)](https://pub.dev/packages/flutter_offline_sync_ui)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/LidhinCS/flutter_offline_sync/blob/main/packages/flutter_offline_sync_ui/LICENSE)

Flutter UI widgets for [flutter_offline_sync_core](https://pub.dev/packages/flutter_offline_sync_core). Watches Drift
job streams and shows sync status per screen or feature.

**Docs:** [UI guide](https://lidhincs.github.io/flutter_offline_sync/guide/ui) ·
[GitHub](https://github.com/LidhinCS/flutter_offline_sync)

## Install

```yaml
dependencies:
  flutter_offline_sync_ui: ^0.1.2
```

## Quick start

```dart
import 'package:flutter_offline_sync_ui/flutter_offline_sync_ui.dart';

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

When enqueueing jobs, set `meta` so list tiles can show a label and record
details (`meta` is free-form per feature):

```dart
await JobBuilder(
  db,
  feature: 'posts',
  screen: 'create_post_screen',
  meta: {
    'label': 'Upload photo',
    'subtitle': 'Site report · doc-123', // optional second line
  },
)
  .addStep('uploadImage', taskType: 'uploadImage', input: {'filePath': path})
  .enqueue();
```

UI conventions: `label` → title, `subtitle` → record line under the title.
Other keys are ignored by the stock tile but available to your app.

## Widgets

| Widget | Purpose |
|---|---|
| `OfflineSyncScope` | Provides `SyncDatabase` + `SyncEngine` to descendants |
| `SyncJobsBuilder` | Rebuilds on `watchJobsForScreen` / `watchJobsForFeature` |
| `SyncStatusBadge` | Compact chip: "2 pending", "1 failed", etc. |
| `SyncActivityIndicator` | Busy chip from push/pull streams (+ optional running jobs) |
| `SyncScreenBanner` | Screen-level banner with job list + discard pending |
| `SyncJobListTile` | Single job row with retry for failed jobs |

### Sync activity chip

```dart
SyncActivityIndicator(
  isPushing: engine.isSyncingStream,
  isPulling: pullCoordinator.isPullingStream,
  initialPushing: engine.isSyncing,
  initialPulling: pullCoordinator.isPulling,
  db: syncDb,           // optional: also light up for JobStatus.running
  feature: 'documents', // or screen: '...'
  pushingLabel: 'Uploading…',
  pullingLabel: 'Updating…',
  busyLabel: 'Syncing…',
);
```

Placement and localized copy belong in the host app; the widget stays generic.

## Helpers

- `countJobs` — group jobs by status
- `activeJobs` — filter out success/cancelled
- `historyJobs` — recent success/cancelled jobs (newest first)
- `jobMetaMap` / `jobDisplayLabel` / `jobDisplaySubtitle` — read `meta`
- `jobStatusAppearance` — icon/color per `JobStatus`

## History without a second database

Successful jobs already stay in `SyncDatabase`. Prefer showing them with
`historyJobs` and optionally calling `SyncDatabase.pruneCompletedJobs`
(default: drop success/cancelled older than 7 days) to bound storage. A
separate history DB is only needed if you must delete outbox step payloads
while keeping a thinner long-term audit log.

This package re-exports `flutter_offline_sync_core`.

## Conflict resolution

`SyncJobListTile` exposes `onConflictTap` for conflicted jobs. Wire it to your
app's resolution UI, then call `engine.resolveConflict(...)`.

## Example

```bash
cd packages/flutter_offline_sync_ui/example
flutter run
```

The example app demonstrates `OfflineSyncScope`, `SyncStatusBadge`,
`SyncScreenBanner`, and `SyncJobListTile` wired to live Drift streams.
