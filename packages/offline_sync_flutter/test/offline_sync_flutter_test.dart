import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_sync_flutter/offline_sync_flutter.dart';

class _CountingHandler extends SyncTaskHandler {
  _CountingHandler(this.onExecute);

  final void Function() onExecute;

  @override
  Future<SyncStepResult> execute(SyncContext ctx) async {
    onExecute();
    return const SyncStepResult.success({'ok': true});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectivitySyncTrigger', () {
    late SyncDatabase db;
    late StreamController<List<ConnectivityResult>> connectivity;
    late int syncHandlerCalls;

    setUp(() {
      db = SyncDatabase.forTesting(NativeDatabase.memory());
      connectivity = StreamController<List<ConnectivityResult>>();
      syncHandlerCalls = 0;
    });

    tearDown(() async {
      await connectivity.close();
      await db.close();
    });

    test('does not sync while offline', () async {
      final registry = SyncHandlerRegistry()
        ..register('task', _CountingHandler(() => syncHandlerCalls++));
      final engine = SyncEngine(db: db, registry: registry);

      await JobBuilder(db, feature: 'f', screen: 's')
          .addStep('step', taskType: 'task', input: const {})
          .enqueue();

      final trigger = ConnectivitySyncTrigger.forTesting(engine, connectivity.stream);
      trigger.start();

      connectivity.add([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);

      expect(syncHandlerCalls, 0);
      await trigger.stop();
    });

    test('syncs when connectivity returns', () async {
      final registry = SyncHandlerRegistry()
        ..register('task', _CountingHandler(() => syncHandlerCalls++));
      final engine = SyncEngine(db: db, registry: registry);

      await JobBuilder(db, feature: 'f', screen: 's')
          .addStep('step', taskType: 'task', input: const {})
          .enqueue();

      final trigger = ConnectivitySyncTrigger.forTesting(engine, connectivity.stream);
      trigger.start();

      connectivity.add([ConnectivityResult.wifi]);
      await pumpEventQueue();

      expect(syncHandlerCalls, 1);
      await trigger.stop();
    });
  });

  group('runBackgroundSync', () {
    test('runs syncAll via engine factory', () async {
      final db = SyncDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      var handlerCalls = 0;
      final registry = SyncHandlerRegistry()
        ..register('task', _CountingHandler(() => handlerCalls++));

      await JobBuilder(db, feature: 'f', screen: 's')
          .addStep('step', taskType: 'task', input: const {})
          .enqueue();

      final result = await runBackgroundSync(() async {
        return SyncEngine(db: db, registry: registry);
      });

      expect(result, isTrue);
      expect(handlerCalls, 1);
    });
  });

  group('FlutterSyncCoordinator', () {
    test('recovers interrupted work and starts connectivity trigger', () async {
      final db = SyncDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final jobId = await db.createJob(
        feature: 'f',
        screen: 's',
        idempotencyKey: 'key',
      );
      await db.addStep(
        jobId: jobId,
        stepKey: 'step',
        taskType: 'task',
        input: const {},
      );
      await db.markJobStatus(jobId, JobStatus.running);
      await db.markStepRunning(1);

      final connectivity = StreamController<List<ConnectivityResult>>();
      addTearDown(connectivity.close);

      var handlerCalls = 0;
      final registry = SyncHandlerRegistry()
        ..register('task', _CountingHandler(() => handlerCalls++));
      final engine = SyncEngine(db: db, registry: registry);
      final coordinator = FlutterSyncCoordinator(engine: engine);

      await coordinator.startForegroundSync();

      final job = await db.jobById(jobId);
      expect(job?.status, JobStatus.pending);

      connectivity.add([ConnectivityResult.mobile]);
      final trigger = ConnectivitySyncTrigger.forTesting(engine, connectivity.stream);
      trigger.start();
      await pumpEventQueue();

      expect(handlerCalls, 1);
      await coordinator.stopForegroundSync();
      await trigger.stop();
    });
  });
}
