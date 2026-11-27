## 0.1.2

### Fixes

- Correct homepage / documentation URLs (`lidhincs.github.io`)
- Raise `drift` lower bound to `^2.35.3`
- Prefer initializing formals in `ConnectivityPullTrigger.forTesting`
- Depend on `flutter_offline_sync_pull: ^0.1.2`

## 0.1.1

Unpublished locally; changes shipped in **0.1.2**.

## 0.1.0

Initial public release.

### Features

- `FlutterPullCoordinator` — connectivity-triggered `runAll`
- `ConnectivityPullTrigger` — listen for network and pull
- `initBackgroundPull` / `runBackgroundPull` / `cancelBackgroundPull` for Workmanager
- Re-exports `flutter_offline_sync_pull`

### Notes

- Pair with `flutter_offline_sync_push` for push + pull in one Workmanager callback
