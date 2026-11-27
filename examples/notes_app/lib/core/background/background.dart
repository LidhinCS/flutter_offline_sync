import 'package:flutter_offline_sync_pull_flutter/flutter_offline_sync_pull_flutter.dart';
import 'package:flutter_offline_sync_push/flutter_offline_sync_push.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/notes/data/datasources/fake_notes_api.dart';
import '../../features/notes/data/datasources/notes_local_datasource.dart';
import '../database/app_database.dart';
import '../sync/registries.dart';

const syncTaskName = 'com.example.offlinesync.notes.syncTask';

/// Single Workmanager entrypoint: push then pull (same order as reconnect).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await runBackgroundSync(createBackgroundSyncEngine);
    await runBackgroundPull(createBackgroundPullCoordinator);
    return true;
  });
}

@pragma('vm:entry-point')
Future<SyncEngine> createBackgroundSyncEngine() async {
  final appDb = AppDatabase();
  final syncDb = SyncDatabase();
  final api = FakeNotesApi();
  final local = NotesLocalDatasource(appDb);
  return SyncEngine(
    db: syncDb,
    registry: buildRegistry(api: api, local: local),
  );
}

@pragma('vm:entry-point')
Future<PullCoordinator> createBackgroundPullCoordinator() async {
  final appDb = AppDatabase();
  final pullDb = PullDatabase();
  final api = FakeNotesApi();
  final local = NotesLocalDatasource(appDb);
  return PullCoordinator(
    db: pullDb,
    registry: buildPullRegistry(api: api, local: local),
  );
}

Future<void> setupBackgroundSync() {
  return initBackgroundSync(
    callbackDispatcher: callbackDispatcher,
    uniqueName: syncTaskName,
    registerPeriodicTask: false,
  );
}
