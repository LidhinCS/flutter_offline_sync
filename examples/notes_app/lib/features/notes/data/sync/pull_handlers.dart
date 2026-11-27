import 'package:flutter_offline_sync_pull_flutter/flutter_offline_sync_pull_flutter.dart';

import '../datasources/fake_notes_api.dart';
import '../datasources/notes_local_datasource.dart';

/// Paginated list pull → upserts into AppDatabase via local datasource.
class NotesListPullHandler extends PullStepHandler {
  NotesListPullHandler(this._api, this._local);

  final FakeNotesApi _api;
  final NotesLocalDatasource _local;

  @override
  Future<PullStepResult> fetch(PullContext ctx) async {
    final page = await _api.fetchPage(page: ctx.page, pageSize: ctx.pageSize);
    for (final note in page.notes) {
      await _local.upsertFromServer(
        serverId: note.id,
        title: note.title,
        body: note.body,
        imageUrl: note.imageUrl,
      );
    }
    return PullStepResult.success(hasMore: page.hasMore);
  }
}
