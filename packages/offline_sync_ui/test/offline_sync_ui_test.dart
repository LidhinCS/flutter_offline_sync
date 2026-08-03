import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_sync_ui/offline_sync_ui.dart';

void main() {
  group('sync job utils', () {
    test('countJobs groups by status', () {
      final jobs = [
        _job(id: 1, status: JobStatus.pending),
        _job(id: 2, status: JobStatus.pending),
        _job(id: 3, status: JobStatus.failed),
        _job(id: 4, status: JobStatus.success),
      ];

      final counts = countJobs(jobs);
      expect(counts.pending, 2);
      expect(counts.failed, 1);
      expect(counts.success, 1);
      expect(counts.active, 2);
      expect(counts.needsAttention, 1);
    });

    test('jobDisplayLabel reads meta.label', () {
      final job = _job(
        id: 1,
        status: JobStatus.pending,
        meta: '{"label":"Upload photo"}',
      );

      expect(jobDisplayLabel(job), 'Upload photo');
      expect(jobDisplayLabel(_job(id: 2, status: JobStatus.pending)), 'Sync job');
    });

    test('activeJobs hides success and cancelled', () {
      final jobs = [
        _job(id: 1, status: JobStatus.pending),
        _job(id: 2, status: JobStatus.success),
        _job(id: 3, status: JobStatus.cancelled),
      ];

      expect(activeJobs(jobs).map((j) => j.id), [1]);
    });
  });

  group('widgets', () {
    late SyncDatabase db;
    late SyncEngine engine;

    setUp(() {
      db = SyncDatabase.forTesting(NativeDatabase.memory());
      engine = SyncEngine(db: db, registry: SyncHandlerRegistry());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('OfflineSyncScope provides db and engine', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OfflineSyncScope(
            db: db,
            engine: engine,
            child: Builder(
              builder: (context) {
                final scope = OfflineSyncScope.of(context);
                return Text(scope.db == db ? 'ok' : 'missing');
              },
            ),
          ),
        ),
      );

      expect(find.text('ok'), findsOneWidget);
    });

    testWidgets('SyncJobListTile shows retry for failed jobs', (tester) async {
      final job = _job(
        id: 1,
        status: JobStatus.failed,
        meta: '{"label":"Create post"}',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncJobListTile(job: job, engine: engine),
          ),
        ),
      );

      expect(find.text('Create post'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('SyncStatusBadge renders pending label from job list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncJobsBuilder(
              db: db,
              screen: 'create_post_screen',
              builder: (context, jobs) {
                final counts = countJobs(jobs);
                return Text('${counts.pending} pending');
              },
            ),
          ),
        ),
      );

      await JobBuilder(
        db,
        feature: 'posts',
        screen: 'create_post_screen',
      )
          .addStep('upload', taskType: 'uploadImage', input: const {})
          .enqueue();

      await tester.pump();
      expect(find.text('1 pending'), findsOneWidget);

      await db.close();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });
}

SyncJob _job({
  required int id,
  required JobStatus status,
  String? meta,
}) {
  return SyncJob(
    id: id,
    feature: 'f',
    screen: 's',
    status: status,
    idempotencyKey: 'key-$id',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    meta: meta,
  );
}
