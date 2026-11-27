import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/notes_table.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Stream<List<Note>> watchAll() {
    return (select(
      notes,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();
  }

  Future<void> upsertLocal(NotesCompanion row) {
    return into(notes).insertOnConflictUpdate(row);
  }

  Future<void> markSynced({
    required String id,
    required String serverId,
    String? imageUrl,
  }) {
    return (update(notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        serverId: Value(serverId),
        imageUrl: Value(imageUrl),
        syncStatus: const Value('synced'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markFailed(String id) {
    return (update(notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        syncStatus: const Value('failed'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> upsertFromServer({
    required String serverId,
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    final existing = await (select(
      notes,
    )..where((t) => t.serverId.equals(serverId))).getSingleOrNull();

    if (existing != null) {
      // Don't overwrite an in-flight local edit still pending push.
      if (existing.syncStatus == 'pending') return;
      await (update(notes)..where((t) => t.id.equals(existing.id))).write(
        NotesCompanion(
          title: Value(title),
          body: Value(body),
          imageUrl: Value(imageUrl),
          syncStatus: const Value('synced'),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return;
    }

    await into(notes).insert(
      NotesCompanion.insert(
        id: 'server-$serverId',
        serverId: Value(serverId),
        title: title,
        body: Value(body),
        imageUrl: Value(imageUrl),
        syncStatus: const Value('synced'),
        updatedAt: DateTime.now(),
      ),
    );
  }
}
