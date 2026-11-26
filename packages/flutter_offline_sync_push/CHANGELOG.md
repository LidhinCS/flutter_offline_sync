## 0.1.0

Initial public release.

### Features

- `FlutterSyncCoordinator` — startup recovery + connectivity-triggered `syncAll`
- `ConnectivitySyncTrigger` — listen for network and drain the outbox
- `initBackgroundSync` / `runBackgroundSync` / `cancelBackgroundSync` for Workmanager
- Re-exports `flutter_offline_sync_core`

### Notes

- Android periodic tasks: minimum 15 minutes
- iOS `BGTaskScheduler` is best-effort; prefer foreground connectivity sync for latency
