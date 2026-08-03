# offline_sync_ui example

Demonstrates UI widgets: `OfflineSyncScope`, `SyncStatusBadge`,
`SyncScreenBanner`, `SyncJobsBuilder`, and `SyncJobListTile`.

## Run

```bash
cd packages/offline_sync_ui/example
flutter pub get
flutter run
```

Enqueue jobs and tap Sync to see widgets update from Drift watch streams.
Handlers are in-memory fakes — see `lib/handlers.dart`.
