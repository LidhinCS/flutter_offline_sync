import 'package:offline_sync_core/offline_sync_core.dart';

/// Simulates an image upload without real HTTP — enough to exercise the engine.
class FakeUploadHandler extends SyncTaskHandler {
  const FakeUploadHandler();

  @override
  Future<SyncStepResult> execute(SyncContext ctx) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final filePath = ctx.input['filePath'] as String;
    return SyncStepResult.success({
      'imageUrl': 'https://cdn.example.com/$filePath',
    });
  }
}

/// Depends on [FakeUploadHandler] output — the upload-then-create pattern.
class FakeCreatePostHandler extends SyncTaskHandler {
  const FakeCreatePostHandler();

  @override
  Future<SyncStepResult> execute(SyncContext ctx) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final imageUrl = ctx.dependencyOutput('uploadImage')['imageUrl'];
    final title = ctx.input['title'] as String;
    return SyncStepResult.success({
      'postId': 'post-${title.hashCode}',
      'imageUrl': imageUrl,
    });
  }
}

SyncHandlerRegistry buildRegistry() {
  return SyncHandlerRegistry()
    ..register('uploadImage', const FakeUploadHandler())
    ..register('createPost', const FakeCreatePostHandler());
}

Future<void> enqueueCreatePostJob(
  SyncDatabase db, {
  required String filePath,
  required String title,
}) {
  return JobBuilder(
    db,
    feature: 'posts',
    screen: 'create_post_screen',
    meta: {'label': 'Create "$title"'},
  )
      .addStep(
        'uploadImage',
        taskType: 'uploadImage',
        input: {'filePath': filePath},
      )
      .addStep(
        'createPost',
        taskType: 'createPost',
        input: {'title': title},
        dependsOn: ['uploadImage'],
      )
      .enqueue();
}
