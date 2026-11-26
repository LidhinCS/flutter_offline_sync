# flutter_offline_sync_core example

Demonstrates the pure-Dart sync engine: enqueue a multi-step job, run
`SyncEngine.syncAll()`, and watch job status update via Drift streams.

## Run

```bash
cd packages/flutter_offline_sync_core/example
flutter pub get
flutter run
```

Handlers in `lib/handlers.dart` are in-memory fakes — no Dio or network
required. For Flutter adapters (Workmanager, connectivity), see
`packages/flutter_offline_sync_push/example`. For UI widgets, see
`packages/flutter_offline_sync_ui/example`.
