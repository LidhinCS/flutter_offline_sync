## 0.1.0

Initial public release.

### Features

- `FlutterPullCoordinator` — connectivity-triggered `runAll`
- `ConnectivityPullTrigger` — listen for network and pull
- `initBackgroundPull` / `runBackgroundPull` / `cancelBackgroundPull` for Workmanager
- Re-exports `flutter_offline_sync_pull`

### Notes

- Pair with `flutter_offline_sync_push` for push + pull in one Workmanager callback
