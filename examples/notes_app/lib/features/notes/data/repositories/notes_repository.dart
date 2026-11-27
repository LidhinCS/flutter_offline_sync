import 'package:flutter_offline_sync_push/flutter_offline_sync_push.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/note.dart' as domain;
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';

/// Data-layer repository: App DB streams + JobBuilder enqueue.
class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl({required this._local, required this._syncDb});

  final NotesLocalDatasource _local;
  final SyncDatabase _syncDb;
  static const _uuid = Uuid();

  static const feature = 'notes';
  static const screen = 'create_note_screen';

  @override
  Stream<List<domain.Note>> watchNotes() {
    return _local.watchNotes().map(
      (rows) => [
        for (final row in rows)
          domain.Note(
            id: row.id,
            serverId: row.serverId,
            title: row.title,
            body: row.body,
            imageUrl: row.imageUrl,
            syncStatus: _parseStatus(row.syncStatus),
            updatedAt: row.updatedAt,
          ),
      ],
    );
  }

  @override
  Future<void> createNote({
    required String title,
    required String body,
    String? attachmentPath,
  }) async {
    final localId = _uuid.v4();

    // 1) Optimistic App DB row so the list updates immediately.
    await _local.insertOptimistic(id: localId, title: title, body: body);

    // 2) Enqueue outbox job in SyncDatabase (not AppDatabase).
    final builder = JobBuilder(
      _syncDb,
      feature: feature,
      screen: screen,
      meta: {'label': 'Create "$title"'},
    );

    if (attachmentPath != null && attachmentPath.isNotEmpty) {
      builder
          .addStep(
            'uploadAttachment',
            taskType: 'uploadAttachment',
            input: {'filePath': attachmentPath},
          )
          .addStep(
            'createNote',
            taskType: 'createNote',
            input: {'localId': localId, 'title': title, 'body': body},
            dependsOn: ['uploadAttachment'],
          );
    } else {
      builder.addStep(
        'createNote',
        taskType: 'createNote',
        input: {'localId': localId, 'title': title, 'body': body},
      );
    }

    await builder.enqueue();
  }

  domain.NoteSyncStatus _parseStatus(String raw) {
    return switch (raw) {
      'synced' => domain.NoteSyncStatus.synced,
      'failed' => domain.NoteSyncStatus.failed,
      _ => domain.NoteSyncStatus.pending,
    };
  }
}
