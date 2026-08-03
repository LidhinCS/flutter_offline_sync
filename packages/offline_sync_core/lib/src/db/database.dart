import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'sync_jobs_table.dart';
import 'sync_steps_table.dart';
import '../models/cross_job_dependency.dart';

part 'database.g.dart';

/// Opens the sync database at a stable path shared by the foreground app
/// isolate and the background WorkManager isolate. WAL mode is required:
/// under the default rollback-journal mode, two isolates/processes with
/// independent connections to the same file will lock each other out.
/// WAL supports concurrent readers + a single writer safely.
LazyDatabase openConnection({String? dbPath}) {
  return LazyDatabase(() async {
    final path = dbPath ?? await _defaultDbPath();
    final file = File(path);
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        rawDb.execute('PRAGMA journal_mode=WAL;');
        rawDb.execute('PRAGMA busy_timeout=5000;');
      },
    );
  });
}

Future<String> _defaultDbPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, 'sync_core.sqlite');
}

@DriftDatabase(tables: [SyncJobs, SyncSteps])
class SyncDatabase extends _$SyncDatabase {
  SyncDatabase({String? dbPath}) : super(openConnection(dbPath: dbPath));

  /// Used by the background isolate, which must open its own connection
  /// to the same file rather than share the foreground app's connection.
  SyncDatabase.forIsolate(String dbPath) : super(openConnection(dbPath: dbPath));

  /// For unit tests: pass e.g. `NativeDatabase.memory()` so tests don't
  /// touch the filesystem or need path_provider.
  SyncDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(syncSteps, syncSteps.externalDependsOn);
          }
        },
      );

  // ---- Job queries -------------------------------------------------

  Future<int> createJob({
    required String feature,
    required String screen,
    required String idempotencyKey,
    Map<String, dynamic>? meta,
  }) {
    return into(syncJobs).insert(
      SyncJobsCompanion.insert(
        feature: feature,
        screen: screen,
        status: JobStatus.pending,
        idempotencyKey: idempotencyKey,
        meta: Value(meta == null ? null : jsonEncode(meta)),
      ),
    );
  }

  Future<int> addStep({
    required int jobId,
    required String stepKey,
    required String taskType,
    required Map<String, dynamic> input,
    List<String> dependsOn = const [],
    List<CrossJobDependency> externalDependsOn = const [],
    int sortIndex = 0,
  }) {
    return into(syncSteps).insert(
      SyncStepsCompanion.insert(
        jobId: jobId,
        stepKey: stepKey,
        taskType: taskType,
        input: jsonEncode(input),
        dependsOn: Value(jsonEncode(dependsOn)),
        externalDependsOn: Value(jsonEncode(
          externalDependsOn.map((d) => d.toJson()).toList(),
        )),
        sortIndex: Value(sortIndex),
        status: StepStatus.pending,
      ),
    );
  }

  Future<SyncJob?> jobById(int jobId) {
    return (select(syncJobs)..where((j) => j.id.equals(jobId)))
        .getSingleOrNull();
  }

  /// Resolves the upstream step referenced by a [CrossJobDependency].
  Future<SyncStep?> resolveCrossJobUpstreamStep(CrossJobDependency dep) async {
    if (dep.jobId != null) {
      final steps = await stepsForJob(dep.jobId!);
      for (final step in steps) {
        if (step.stepKey == dep.stepKey) return step;
      }
      return null;
    }

    final jobs = await (select(syncJobs)
          ..where((j) =>
              j.screen.equals(dep.screen!) &
              (j.status.equalsValue(JobStatus.pending) |
                  j.status.equalsValue(JobStatus.running) |
                  j.status.equalsValue(JobStatus.success) |
                  j.status.equalsValue(JobStatus.failed) |
                  j.status.equalsValue(JobStatus.conflict)))
          ..orderBy([(j) => OrderingTerm.desc(j.createdAt)]))
        .get();

    for (final job in jobs) {
      if (dep.feature != null && job.feature != dep.feature) continue;
      final steps = await stepsForJob(job.id);
      for (final step in steps) {
        if (step.stepKey == dep.stepKey) return step;
      }
    }
    return null;
  }

  Future<List<SyncStep>> stepsForJob(int jobId) {
    return (select(syncSteps)
          ..where((s) => s.jobId.equals(jobId))
          ..orderBy([(s) => OrderingTerm.asc(s.sortIndex)]))
        .get();
  }

  Future<List<SyncJob>> pendingJobs() {
    return (select(syncJobs)
          ..where((j) => j.status.equalsValue(JobStatus.pending))
          ..orderBy([(j) => OrderingTerm.asc(j.createdAt)]))
        .get();
  }

  /// Jobs left in `running` because the app/isolate was killed mid-sync --
  /// there is no live runJob() call still iterating them. Used at startup
  /// to recover before the next real sync pass.
  Future<List<SyncJob>> runningJobs() {
    return (select(syncJobs)..where((j) => j.status.equalsValue(JobStatus.running))).get();
  }

  /// Steps left in `running` for the same reason -- interrupted mid-execute,
  /// not actually in flight.
  Future<List<SyncStep>> runningSteps() {
    return (select(syncSteps)..where((s) => s.status.equalsValue(StepStatus.running))).get();
  }

  Stream<List<SyncJob>> watchJobsForScreen(String screen) {
    return (select(syncJobs)..where((j) => j.screen.equals(screen))).watch();
  }

  Stream<List<SyncJob>> watchJobsForFeature(String feature) {
    return (select(syncJobs)..where((j) => j.feature.equals(feature))).watch();
  }

  Future<void> markJobStatus(int jobId, JobStatus status) {
    return (update(syncJobs)..where((j) => j.id.equals(jobId))).write(
      SyncJobsCompanion(status: Value(status), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> cancelJobsForScreen(String screen) async {
    await (update(syncJobs)
          ..where((j) => j.screen.equals(screen) & j.status.equalsValue(JobStatus.pending)))
        .write(const SyncJobsCompanion(status: Value(JobStatus.cancelled)));
  }

  // ---- Step queries --------------------------------------------------

  Future<void> markStepRunning(int stepId) {
    return (update(syncSteps)..where((s) => s.id.equals(stepId))).write(
      const SyncStepsCompanion(status: Value(StepStatus.running)),
    );
  }

  Future<void> markStepSuccess(int stepId, Map<String, dynamic> output) {
    return (update(syncSteps)..where((s) => s.id.equals(stepId))).write(
      SyncStepsCompanion(
        status: const Value(StepStatus.success),
        output: Value(jsonEncode(output)),
        completedAt: Value(DateTime.now()),
        lastError: const Value(null),
      ),
    );
  }

  Future<void> markStepFailed(int stepId, String error) {
    return (update(syncSteps)..where((s) => s.id.equals(stepId))).write(
      SyncStepsCompanion(
        status: const Value(StepStatus.failed),
        lastError: Value(error),
      ),
    );
  }

  Future<void> markStepConflict(int stepId, Map<String, dynamic> serverState) {
    return (update(syncSteps)..where((s) => s.id.equals(stepId))).write(
      SyncStepsCompanion(
        status: const Value(StepStatus.conflict),
        conflictData: Value(jsonEncode(serverState)),
      ),
    );
  }

  Future<void> resetStepToPending(int stepId) {
    return (update(syncSteps)..where((s) => s.id.equals(stepId))).write(
      const SyncStepsCompanion(
        status: Value(StepStatus.pending),
        lastError: Value(null),
        conflictData: Value(null),
      ),
    );
  }

  Future<void> bumpAttempt(int stepId, int attempt, DateTime? nextRetryAt) {
    return (update(syncSteps)..where((s) => s.id.equals(stepId))).write(
      SyncStepsCompanion(
        attempt: Value(attempt),
        nextRetryAt: Value(nextRetryAt),
      ),
    );
  }

  // ---- Cross-isolate lock ---------------------------------------------
  // Prevents the foreground sync loop and a background WorkManager pass
  // from running the same job concurrently. A single row, claimed via a
  // conditional update; if rows-affected == 0, someone else holds the lock.

  Future<bool> tryAcquireLock({required Duration ttl}) async {
    final now = DateTime.now();
    final until = now.add(ttl);
    await customStatement(
      'CREATE TABLE IF NOT EXISTS sync_lock (id INTEGER PRIMARY KEY CHECK (id = 1), locked_until INTEGER NOT NULL DEFAULT 0)',
    );
    await customStatement(
      'INSERT OR IGNORE INTO sync_lock (id, locked_until) VALUES (1, 0)',
    );
    final rows = await customUpdate(
      'UPDATE sync_lock SET locked_until = ? WHERE id = 1 AND locked_until < ?',
      variables: [
        Variable.withInt(until.millisecondsSinceEpoch),
        Variable.withInt(now.millisecondsSinceEpoch),
      ],
      updates: {},
    );
    return rows == 1;
  }

  Future<void> releaseLock() async {
    await customUpdate(
      'UPDATE sync_lock SET locked_until = 0 WHERE id = 1',
      updates: {},
    );
  }
}
