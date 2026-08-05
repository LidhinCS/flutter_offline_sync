import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'pull_checkpoints_table.dart';

part 'database.g.dart';

LazyDatabase openPullConnection({String? dbPath}) {
  return LazyDatabase(() async {
    final path = dbPath ?? await _defaultDbPath();
    final file = File(path);
    return NativeDatabase.createInBackground(file);
  });
}

Future<String> _defaultDbPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, 'offline_sync_pull.sqlite');
}

@DriftDatabase(tables: [PullCheckpoints])
class PullDatabase extends _$PullDatabase {
  PullDatabase({String? dbPath}) : super(openPullConnection(dbPath: dbPath));

  PullDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<PullCheckpoint?> checkpointFor(String feature, String stepKey) {
    return (select(pullCheckpoints)
          ..where((c) => c.feature.equals(feature) & c.stepKey.equals(stepKey)))
        .getSingleOrNull();
  }

  Future<void> upsertCheckpoint({
    required String feature,
    required String stepKey,
    required int page,
    required int pageSize,
    required PullStepStatus status,
    required bool hasMore,
    String? lastError,
  }) async {
    final existing = await checkpointFor(feature, stepKey);
    if (existing == null) {
      await into(pullCheckpoints).insert(
        PullCheckpointsCompanion.insert(
          feature: feature,
          stepKey: stepKey,
          page: Value(page),
          pageSize: Value(pageSize),
          status: status,
          hasMore: Value(hasMore),
          lastRunAt: Value(DateTime.now()),
          lastError: Value(lastError),
        ),
      );
      return;
    }

    await (update(pullCheckpoints)..where((c) => c.id.equals(existing.id))).write(
      PullCheckpointsCompanion(
        page: Value(page),
        pageSize: Value(pageSize),
        status: Value(status),
        hasMore: Value(hasMore),
        lastRunAt: Value(DateTime.now()),
        lastError: Value(lastError),
      ),
    );
  }

  Future<void> resetCheckpoint(String feature, String stepKey) {
    return upsertCheckpoint(
      feature: feature,
      stepKey: stepKey,
      page: 1,
      pageSize: 10,
      status: PullStepStatus.pending,
      hasMore: true,
      lastError: null,
    );
  }
}
