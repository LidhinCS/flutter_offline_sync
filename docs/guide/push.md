# Push (write queue)

The push path queues **offline writes** as jobs and steps, then runs them through your handlers when online.

## Quick start

```dart
import 'package:offline_sync_flutter/offline_sync_flutter.dart';

final registry = SyncHandlerRegistry()
  ..register('uploadImage', UploadImageHandler(dio))
  ..register('createPost', CreatePostHandler(dio));

final db = SyncDatabase();
final engine = SyncEngine(db: db, registry: registry);

await JobBuilder(db, feature: 'posts', screen: 'create_post_screen')
    .addStep('uploadImage', taskType: 'uploadImage', input: {'filePath': path})
    .addStep(
      'createPost',
      taskType: 'createPost',
      input: {'title': title},
      dependsOn: ['uploadImage'],
    )
    .enqueue();

await engine.syncAll();
```

## Writing a handler

```dart
class UploadImageHandler extends SyncTaskHandler {
  const UploadImageHandler(this.dio);
  final Dio dio;

  @override
  Future<SyncStepResult> execute(SyncContext ctx) async {
    final path = ctx.input['filePath'] as String;
    final resp = await dio.post('/upload', data: FormData.fromMap({
      'file': await MultipartFile.fromFile(path),
    }));
    return SyncStepResult.success({'imageUrl': resp.data['url']});
  }
}
```

Downstream steps use `ctx.dependencyOutput('uploadImage')`.

## Partial retry

`engine.retryJob(jobId)` resets only **failed** steps. Successful steps keep their output unless `isOutputStillValid` returns false (e.g. expired presigned URL).

## Conflicts

Return `SyncStepResult.conflict(serverState)` for 409-style responses — not `.failure`. Resolve with:

```dart
await engine.resolveConflict(jobId, 'createPost', resolvedFields);
```

## Optimistic UI

Enqueue via `JobBuilder` into `SyncDatabase`. Optionally upsert into **AppDatabase** in your repository before enqueue so lists update immediately.

## Flutter adapter

Use [offline_sync_flutter](/packages/offline_sync_flutter) for:

- `FlutterSyncCoordinator` — connectivity + startup recovery
- `runBackgroundSync` + Workmanager

See [Foreground & background](/guide/foreground-background).

## Package reference

[offline_sync_core](/packages/offline_sync_core) · [offline_sync_flutter](/packages/offline_sync_flutter)
