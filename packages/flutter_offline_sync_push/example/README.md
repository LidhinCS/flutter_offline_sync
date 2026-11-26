# flutter_offline_sync_push example

Demonstrates Flutter adapters: `FlutterSyncCoordinator`, connectivity-triggered
foreground sync, and Workmanager background setup.

## Run

```bash
cd packages/flutter_offline_sync_push/example
flutter pub get
flutter run
```

Periodic background sync is disabled in this demo (`registerPeriodicTask: false`).
Handlers are in-memory fakes — see `lib/handlers.dart`.
