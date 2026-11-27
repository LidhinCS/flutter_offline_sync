import 'package:flutter_offline_sync_pull_flutter/flutter_offline_sync_pull_flutter.dart';
import 'package:flutter_offline_sync_push/flutter_offline_sync_push.dart';

import '../../features/notes/data/datasources/fake_notes_api.dart';
import '../../features/notes/data/datasources/notes_local_datasource.dart';
import '../../features/notes/data/repositories/notes_repository.dart';
import '../../features/notes/domain/repositories/notes_repository.dart';
import '../database/app_database.dart';
import 'reconnect.dart';
import 'registries.dart';

/// Manual composition root — clearer than Injectable for a teaching example.
class AppServices {
  AppServices._({
    required this.appDb,
    required this.syncDb,
    required this.pullDb,
    required this.engine,
    required this.pullCoordinator,
    required this.pushCoordinator,
    required this.flutterPullCoordinator,
    required this.notesRepository,
    required this.api,
  });

  final AppDatabase appDb;
  final SyncDatabase syncDb;
  final PullDatabase pullDb;
  final SyncEngine engine;
  final PullCoordinator pullCoordinator;
  final FlutterSyncCoordinator pushCoordinator;
  final FlutterPullCoordinator flutterPullCoordinator;
  final NotesRepository notesRepository;
  final FakeNotesApi api;

  static Future<AppServices> bootstrap() async {
    final appDb = AppDatabase();
    final syncDb = SyncDatabase();
    final pullDb = PullDatabase();
    final api = FakeNotesApi();
    final local = NotesLocalDatasource(appDb);

    final engine = SyncEngine(
      db: syncDb,
      registry: buildRegistry(api: api, local: local),
    );
    final pullCoordinator = PullCoordinator(
      db: pullDb,
      registry: buildPullRegistry(api: api, local: local),
    );

    final pushCoordinator = FlutterSyncCoordinator(engine: engine);
    final flutterPullCoordinator = FlutterPullCoordinator(
      coordinator: pullCoordinator,
    );

    return AppServices._(
      appDb: appDb,
      syncDb: syncDb,
      pullDb: pullDb,
      engine: engine,
      pullCoordinator: pullCoordinator,
      pushCoordinator: pushCoordinator,
      flutterPullCoordinator: flutterPullCoordinator,
      notesRepository: NotesRepositoryImpl(local: local, syncDb: syncDb),
      api: api,
    );
  }

  Future<void> startForeground() async {
    await pushCoordinator.startForegroundSync();
    await flutterPullCoordinator.startForegroundPull();
    // Initial pull so the list isn't empty on first launch.
    await pullCoordinator.runAll();
  }

  Future<void> syncNow() {
    return reconnectSync(engine: engine, pullCoordinator: pullCoordinator);
  }

  Future<void> dispose() async {
    await pushCoordinator.stopForegroundSync();
    await flutterPullCoordinator.stopForegroundPull();
    await appDb.close();
    await syncDb.close();
    await pullDb.close();
  }
}
