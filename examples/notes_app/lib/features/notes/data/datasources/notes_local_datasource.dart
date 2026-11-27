import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../daos/notes_dao.dart';

/// Thin wrapper over [NotesDao] — pull/push handlers upsert through here.
class NotesLocalDatasource {
  NotesLocalDatasource(this._db);

  final AppDatabase _db;

  NotesDao get _dao => _db.notesDao;

  /// Drift-generated [Note] rows (table [Notes]).
  Stream<List<Note>> watchNotes() => _dao.watchAll();

  Future<void> insertOptimistic({
    required String id,
    required String title,
    required String body,
  }) {
    return _dao.upsertLocal(
      NotesCompanion.insert(
        id: id,
        title: title,
        body: Value(body),
        syncStatus: const Value('pending'),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> markSynced({
    required String id,
    required String serverId,
    String? imageUrl,
  }) {
    return _dao.markSynced(id: id, serverId: serverId, imageUrl: imageUrl);
  }

  Future<void> markFailed(String id) => _dao.markFailed(id);

  Future<void> upsertFromServer({
    required String serverId,
    required String title,
    required String body,
    String? imageUrl,
  }) {
    return _dao.upsertFromServer(
      serverId: serverId,
      title: title,
      body: body,
      imageUrl: imageUrl,
    );
  }
}
