## 0.1.2

### Fixes

- Correct homepage / documentation URLs (`lidhincs.github.io`)
- Raise `drift` lower bound to `^2.35.3`
- Migrate widgets from deprecated `package:flutter/material.dart` to `package:material_ui`
- Require Flutter `>=3.47.0` / Dart `^3.13.0` (for `material_ui`)
- Remove unnecessary library name
- Depend on `flutter_offline_sync_core: ^0.1.2`

## 0.1.1

Unpublished locally; changes shipped in **0.1.2**.

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
