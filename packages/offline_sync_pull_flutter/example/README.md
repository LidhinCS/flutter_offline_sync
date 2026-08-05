# offline_sync_pull_flutter example

Demonstrates `FlutterPullCoordinator`, connectivity-triggered foreground pull,
and Workmanager setup (`initBackgroundPull` with `registerPeriodicTask: false`).

Fake pull handlers sync into an in-memory store — in a real app you upsert into
your `AppDatabase`.

```bash
flutter run
```
