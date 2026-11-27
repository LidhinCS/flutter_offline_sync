## 0.1.2

### Fixes

- Correct homepage / documentation URLs (`lidhincs.github.io`)
- Raise `drift` lower bound to `^2.35.3`
- Depend on `flutter_offline_sync_core: ^0.1.2`

## 0.1.1

Unpublished locally; changes shipped in **0.1.2**.

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
