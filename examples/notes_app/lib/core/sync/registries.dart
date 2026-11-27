import 'package:flutter_offline_sync_pull_flutter/flutter_offline_sync_pull_flutter.dart';
import 'package:flutter_offline_sync_push/flutter_offline_sync_push.dart';

import '../../features/notes/data/datasources/fake_notes_api.dart';
import '../../features/notes/data/datasources/notes_local_datasource.dart';
import '../../features/notes/data/sync/pull_handlers.dart';
import '../../features/notes/data/sync/push_handlers.dart';

/// Push handlers — register every taskType you enqueue.
SyncHandlerRegistry buildRegistry({
  required FakeNotesApi api,
  required NotesLocalDatasource local,
}) {
  return SyncHandlerRegistry()
    ..register('uploadAttachment', UploadAttachmentHandler(api))
    ..register('createNote', CreateNoteHandler(api, local));
}

/// Pull features — one feature with a paginated list step.
PullFeatureRegistry buildPullRegistry({
  required FakeNotesApi api,
  required NotesLocalDatasource local,
}) {
  return PullFeatureRegistry()..register(
    PullFeature(
      name: 'notes',
      maxPagesPerRun: 2,
      steps: [
        PaginatedListPullStep(
          key: 'list',
          pageSize: FakeNotesApi.pageSize,
          handler: NotesListPullHandler(api, local),
        ),
      ],
    ),
  );
}
