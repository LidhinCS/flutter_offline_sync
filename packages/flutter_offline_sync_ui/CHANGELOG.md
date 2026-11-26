## 0.1.0

Initial public release.

### Features

- `OfflineSyncScope` — provides `SyncDatabase` + `SyncEngine`
- `SyncJobsBuilder` — rebuild on screen/feature job streams
- `SyncStatusBadge` — compact pending/failed counts
- `SyncActivityIndicator` — busy chip from push/pull streams (+ optional running jobs)
- `SyncScreenBanner` — screen-level banner with discard pending
- `SyncJobListTile` — job row with retry; reads `meta.label` / `meta.subtitle`
- Helpers: `countJobs`, `activeJobs`, `historyJobs`, `jobDisplayLabel`, `jobDisplaySubtitle`
- Re-exports `flutter_offline_sync_core`
