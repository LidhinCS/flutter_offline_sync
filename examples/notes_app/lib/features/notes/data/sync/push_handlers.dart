import 'package:flutter_offline_sync_push/flutter_offline_sync_push.dart';

import '../datasources/fake_notes_api.dart';
import '../datasources/notes_local_datasource.dart';

/// Step 1 of the upload-then-create DAG.
class UploadAttachmentHandler extends SyncTaskHandler {
  UploadAttachmentHandler(this._api);

  final FakeNotesApi _api;

  @override
  Future<SyncStepResult> execute(SyncContext ctx) async {
    final filePath = ctx.input['filePath'] as String;
    final url = await _api.uploadAttachment(filePath);
    return SyncStepResult.success({'imageUrl': url});
  }
}

/// Creates the note on the fake server, then marks the local App DB row synced.
class CreateNoteHandler extends SyncTaskHandler {
  CreateNoteHandler(this._api, this._local);

  final FakeNotesApi _api;
  final NotesLocalDatasource _local;

  @override
  Future<SyncStepResult> execute(SyncContext ctx) async {
    final localId = ctx.input['localId'] as String;
    final title = ctx.input['title'] as String;
    final body = ctx.input['body'] as String? ?? '';

    String? imageUrl = ctx.input['imageUrl'] as String?;
    if (ctx.dependencyOutputs.containsKey('uploadAttachment')) {
      imageUrl =
          ctx.dependencyOutput('uploadAttachment')['imageUrl'] as String?;
    }

    try {
      final created = await _api.createNoteDto(
        title: title,
        body: body,
        imageUrl: imageUrl,
        idempotencyKey: ctx.idempotencyKey,
      );
      await _local.markSynced(
        id: localId,
        serverId: created.id,
        imageUrl: created.imageUrl,
      );
      return SyncStepResult.success({
        'serverId': created.id,
        'imageUrl': created.imageUrl,
      });
    } catch (e) {
      await _local.markFailed(localId);
      return SyncStepResult.failure(e.toString());
    }
  }
}
