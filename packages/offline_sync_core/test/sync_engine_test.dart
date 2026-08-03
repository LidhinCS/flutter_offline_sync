import 'dart:async';

import 'package:drift/native.dart';
import 'package:offline_sync_core/offline_sync_core.dart';
import 'package:test/test.dart';

/// Handler double: succeeds N times after `failUntilAttempt` failures, so
/// tests can exercise retry without a real network.
class FakeHandler extends SyncTaskHandler {
  FakeHandler({
    this.failUntilAttempt = 0,
    this.conflictOnce = false,
    required this.outputBuilder,
  });

  final int failUntilAttempt;
  final bool conflictOnce;
  final Map<String, dynamic> Function(SyncContext ctx) outputBuilder;

  int calls = 0;
  bool _conflicted = false;

  @override
  Future<SyncStepResult> execute(SyncContext ctx) async {
    calls++;
    if (conflictOnce && !_conflicted) {
      _conflicted = true;
      return const SyncStepResult.conflict({'server': 'newer'});
    }
    if (calls <= failUntilAttempt) {
      return const SyncStepResult.failure('boom', retryable: true);
    }
    return SyncStepResult.success(outputBuilder(ctx));
  }
}

void main() {
  late SyncDatabase db;

  setUp(() {
    db = SyncDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('dependent steps: downstream sees upstream output', () async {
    final upload = FakeHandler(outputBuilder: (_) => {'imageUrl': 'https://x/1.png'});
    late String receivedUrl;
    final create = FakeHandler(outputBuilder: (ctx) {
      receivedUrl = ctx.dependencyOutput('uploadImage')['imageUrl'] as String;
      return {'postId': 42};
    });

    final registry = SyncHandlerRegistry()
      ..register('uploadImage', upload)
      ..register('createPost', create);

    final jobId = await JobBuilder(db, feature: 'posts', screen: 'create_post_screen')
        .addStep('uploadImage', taskType: 'uploadImage', input: {'filePath': '/tmp/a.png'})
        .addStep('createPost', taskType: 'createPost', input: {'title': 'hi'}, dependsOn: ['uploadImage'])
        .enqueue();

    final engine = SyncEngine(db: db, registry: registry);
    await engine.runJob(jobId);

    expect(receivedUrl, 'https://x/1.png');
    final job = await (db.select(db.syncJobs)..where((j) => j.id.equals(jobId))).getSingle();
    expect(job.status, JobStatus.success);
  });

  test('partial retry: successful step is not re-executed', () async {
    final upload = FakeHandler(outputBuilder: (_) => {'imageUrl': 'https://x/1.png'});
    final create = FakeHandler(failUntilAttempt: 1, outputBuilder: (_) => {'postId': 1});

    final registry = SyncHandlerRegistry()
      ..register('uploadImage', upload)
      ..register('createPost', create);

    final jobId = await JobBuilder(db, feature: 'posts', screen: 's')
        .addStep('uploadImage', taskType: 'uploadImage', input: {})
        .addStep('createPost', taskType: 'createPost', input: {}, dependsOn: ['uploadImage'])
        .enqueue();

    final engine = SyncEngine(db: db, registry: registry);
    await engine.runJob(jobId); // createPost fails once here
    var job = await (db.select(db.syncJobs)..where((j) => j.id.equals(jobId))).getSingle();
    expect(job.status, JobStatus.failed);
    expect(upload.calls, 1);

    await engine.retryJob(jobId); // should NOT re-run uploadImage
    job = await (db.select(db.syncJobs)..where((j) => j.id.equals(jobId))).getSingle();
    expect(job.status, JobStatus.success);
    expect(upload.calls, 1, reason: 'successful step must be reused, not re-executed');
    expect(create.calls, 2);
  });

  test('conflict halts the job and does not run downstream steps', () async {
    final create = FakeHandler(conflictOnce: true, outputBuilder: (_) => {'postId': 1});
    final notify = FakeHandler(outputBuilder: (_) => {'notified': true});

    final registry = SyncHandlerRegistry()
      ..register('createPost', create)
      ..register('notify', notify);

    final jobId = await JobBuilder(db, feature: 'posts', screen: 's')
        .addStep('createPost', taskType: 'createPost', input: {})
        .addStep('notify', taskType: 'notify', input: {}, dependsOn: ['createPost'])
        .enqueue();

    final engine = SyncEngine(db: db, registry: registry);
    await engine.runJob(jobId);

    var job = await (db.select(db.syncJobs)..where((j) => j.id.equals(jobId))).getSingle();
    expect(job.status, JobStatus.conflict);
    expect(notify.calls, 0, reason: 'downstream step must not run while upstream is conflicted');

    await engine.resolveConflict(jobId, 'createPost', {'postId': 1});
    job = await (db.select(db.syncJobs)..where((j) => j.id.equals(jobId))).getSingle();
    expect(job.status, JobStatus.success);
    expect(notify.calls, 1);
  });

  test('recovery resets steps/jobs stuck in running after a simulated restart', () async {
    final handler = FakeHandler(outputBuilder: (_) => {'ok': true});
    final registry = SyncHandlerRegistry()..register('task', handler);

    final jobId = await JobBuilder(db, feature: 'f', screen: 's')
        .addStep('step1', taskType: 'task', input: {})
        .enqueue();

    // Simulate the app being killed mid-execute: step and job left `running`
    // with no live runJob() call actually awaiting them.
    final steps = await db.stepsForJob(jobId);
    await db.markStepRunning(steps.first.id);
    await db.markJobStatus(jobId, JobStatus.running);

    final engine = SyncEngine(db: db, registry: registry);
    await engine.recoverInterruptedWork();

    final step = (await db.stepsForJob(jobId)).first;
    expect(step.status, StepStatus.pending, reason: 'stuck running step must be recovered to pending');
    final job = await (db.select(db.syncJobs)..where((j) => j.id.equals(jobId))).getSingle();
    expect(job.status, JobStatus.pending, reason: 'stuck running job must be recovered to pending');

    // And recovery should let it actually complete on the next real pass.
    await engine.syncAll();
    final finalJob = await (db.select(db.syncJobs)..where((j) => j.id.equals(jobId))).getSingle();
    expect(finalJob.status, JobStatus.success);
  });

  test('cross-job dependency: screen Y waits for screen X and receives mapped id', () async {
    final submitX = FakeHandler(outputBuilder: (_) => {'id': 99, 'name': 'parent'});
    late int receivedParentId;
    final submitY = FakeHandler(outputBuilder: (ctx) {
      receivedParentId = ctx.input['parentId'] as int;
      return {'childId': 7};
    });

    final registry = SyncHandlerRegistry()
      ..register('submitX', submitX)
      ..register('submitY', submitY);

    final engine = SyncEngine(db: db, registry: registry);

    final parentJobId = await JobBuilder(db, feature: 'forms', screen: 'screen_x')
        .addStep('submitX', taskType: 'submitX', input: {'name': 'parent'})
        .enqueue();

    final childJobId = await JobBuilder(db, feature: 'forms', screen: 'screen_y')
        .addStep(
          'submitY',
          taskType: 'submitY',
          input: {'title': 'child'},
          externalDependsOn: [
            CrossJobDependency(
              jobId: parentJobId,
              stepKey: 'submitX',
              mappings: [FieldMapping(from: 'id', to: 'parentId')],
            ),
          ],
        )
        .enqueue();

    // Child alone cannot run before parent succeeds.
    await engine.runJob(childJobId);
    var childJob =
        await (db.select(db.syncJobs)..where((j) => j.id.equals(childJobId))).getSingle();
    expect(childJob.status, JobStatus.pending);
    expect(submitY.calls, 0);

    await engine.syncAll();

    expect(submitX.calls, 1);
    expect(submitY.calls, 1);
    expect(receivedParentId, 99);

    childJob =
        await (db.select(db.syncJobs)..where((j) => j.id.equals(childJobId))).getSingle();
    expect(childJob.status, JobStatus.success);
  });

  test('cross-job dependency: nested field mapping', () async {
    final submitX = FakeHandler(
      outputBuilder: (_) => {'data': {'postId': 42}},
    );
    late int receivedId;
    final submitY = FakeHandler(outputBuilder: (ctx) {
      receivedId = ctx.input['body']['postId'] as int;
      return {'ok': true};
    });

    final registry = SyncHandlerRegistry()
      ..register('submitX', submitX)
      ..register('submitY', submitY);

    final parentJobId = await JobBuilder(db, feature: 'f', screen: 'x')
        .addStep('submitX', taskType: 'submitX', input: {})
        .enqueue();

    await JobBuilder(db, feature: 'f', screen: 'y')
        .addStep(
          'submitY',
          taskType: 'submitY',
          input: {'body': <String, dynamic>{}},
          externalDependsOn: [
            CrossJobDependency(
              jobId: parentJobId,
              stepKey: 'submitX',
              mappings: [FieldMapping(from: 'data.postId', to: 'body.postId')],
            ),
          ],
        )
        .enqueue();

    await SyncEngine(db: db, registry: registry).syncAll();
    expect(receivedId, 42);
  });

  test('a syncAll() call arriving mid-drain coalesces into one more pass instead of being dropped', () async {
    // A handler that blocks until we release it, so we can deterministically
    // call syncAll() again *while* the first pass is still draining.
    final gate = Completer<void>();
    var callCount = 0;
    final registry = SyncHandlerRegistry()
      ..register('slow', _GatedHandler(gate: gate, onCall: () => callCount++));

    final jobId = await JobBuilder(db, feature: 'f', screen: 's')
        .addStep('step1', taskType: 'slow', input: {})
        .enqueue();

    final engine = SyncEngine(db: db, registry: registry);

    final firstPass = engine.syncAll();
    await Future<void>.delayed(Duration.zero); // let the first pass start draining

    // This second call should coalesce (set _rerunRequested) rather than
    // being dropped, since the first pass hasn't released the gate yet.
    final secondPass = engine.syncAll();

    gate.complete();
    await Future.wait([firstPass, secondPass]);

    final job = await (db.select(db.syncJobs)..where((j) => j.id.equals(jobId))).getSingle();
    expect(job.status, JobStatus.success);
    expect(callCount, 1, reason: 'job should complete once, not run twice concurrently');
  });
}

/// Handler that awaits an external gate before resolving -- lets a test hold
/// a sync pass open to exercise coalescing deterministically.
class _GatedHandler extends SyncTaskHandler {
  _GatedHandler({required this.gate, required this.onCall});
  final Completer<void> gate;
  final void Function() onCall;

  @override
  Future<SyncStepResult> execute(SyncContext ctx) async {
    onCall();
    await gate.future;
    return const SyncStepResult.success({'done': true});
  }
}
