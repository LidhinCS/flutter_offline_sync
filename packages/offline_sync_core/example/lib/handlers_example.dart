import 'package:dio/dio.dart';
import 'package:offline_sync_core/offline_sync_core.dart';

/// Uploads a local file and returns a permanent, non-expiring URL. Because
/// the URL never changes or expires, the default isOutputStillValid
/// (always true) is correct here -- no override needed.
class UploadImageHandler extends SyncTaskHandler {
  const UploadImageHandler(this.dio);
  final Dio dio;

  @override
  Future<SyncStepResult> execute(SyncContext ctx) async {
    final filePath = ctx.input['filePath'] as String;
    try {
      final resp = await dio.post(
        '/upload',
        data: FormData.fromMap({'file': await MultipartFile.fromFile(filePath)}),
        options: Options(headers: {'Idempotency-Key': ctx.idempotencyKey}),
      );
      return SyncStepResult.success({'imageUrl': resp.data['url'] as String});
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return SyncStepResult.conflict(e.response?.data as Map<String, dynamic>? ?? {});
      }
      // 4xx other than 409 usually won't succeed on retry without user
      // action (e.g. file too large); 5xx / network errors are retryable.
      final retryable = e.response == null || (e.response!.statusCode ?? 500) >= 500;
      return SyncStepResult.failure(e.message ?? 'upload failed', retryable: retryable);
    }
  }
}

/// Depends on uploadImage's output. Demonstrates the "second call needs an
/// id/url from the first call" pattern from the original requirement.
class CreatePostHandler extends SyncTaskHandler {
  const CreatePostHandler(this.dio);
  final Dio dio;

  @override
  Future<SyncStepResult> execute(SyncContext ctx) async {
    final imageUrl = ctx.dependencyOutput('uploadImage')['imageUrl'];
    try {
      final resp = await dio.post(
        '/posts',
        data: {'title': ctx.input['title'], 'imageUrl': imageUrl},
        options: Options(headers: {'Idempotency-Key': ctx.idempotencyKey}),
      );
      return SyncStepResult.success({'postId': resp.data['id']});
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return SyncStepResult.conflict(e.response?.data as Map<String, dynamic>? ?? {});
      }
      final retryable = e.response == null || (e.response!.statusCode ?? 500) >= 500;
      return SyncStepResult.failure(e.message ?? 'create post failed', retryable: retryable);
    }
  }
}

/// Registers every handler this app knows about. Call this both at app
/// startup AND at the top of the WorkManager background callback --
/// the background isolate has no shared memory with the running app, so
/// the registry must be rebuilt there too.
SyncHandlerRegistry buildRegistry(Dio dio) {
  return SyncHandlerRegistry()
    ..register('uploadImage', UploadImageHandler(dio))
    ..register('createPost', CreatePostHandler(dio));
}

/// Enqueuing the dependent job from a screen: image upload, then create
/// post using its URL -- the exact scenario from the original spec.
Future<void> enqueueCreatePostJob(SyncDatabase db, {
  required String filePath,
  required String title,
}) async {
  await JobBuilder(db, feature: 'posts', screen: 'create_post_screen')
      .addStep('uploadImage', taskType: 'uploadImage', input: {'filePath': filePath})
      .addStep(
        'createPost',
        taskType: 'createPost',
        input: {'title': title},
        dependsOn: ['uploadImage'],
      )
      .enqueue();
}
