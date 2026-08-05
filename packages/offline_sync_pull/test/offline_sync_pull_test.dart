import 'package:drift/native.dart';
import 'package:offline_sync_pull/offline_sync_pull.dart';
import 'package:test/test.dart';

class FakeListHandler extends PullStepHandler {
  FakeListHandler(this.pages);

  final List<List<String>> pages;
  int calls = 0;

  @override
  Future<PullStepResult> fetch(PullContext ctx) async {
    final index = ctx.page - 1;
    if (index >= pages.length) {
      return const PullStepResult.success(hasMore: false);
    }
    calls++;
    final hasMore = index < pages.length - 1;
    return PullStepResult.success(hasMore: hasMore);
  }
}

class FakeBatchHandler extends PullStepHandler {
  final Set<String> synced = {};

  @override
  Future<PullStepResult> fetch(PullContext ctx) async {
    synced.addAll(ctx.entityIds);
    return const PullStepResult.success();
  }
}

class _TrackingBatchHandler extends PullStepHandler {
  _TrackingBatchHandler(this.remaining);

  final Set<String> remaining;
  final Set<String> synced = {};

  @override
  Future<PullStepResult> fetch(PullContext ctx) async {
    synced.addAll(ctx.entityIds);
    for (final id in ctx.entityIds) {
      remaining.remove(id);
    }
    return const PullStepResult.success();
  }
}

void main() {
  late PullDatabase db;

  setUp(() {
    db = PullDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('paginated list advances checkpoint across runs', () async {
    final handler = FakeListHandler([
      ['a', 'b'],
      ['c'],
    ]);

    final registry = PullFeatureRegistry()
      ..register(
        PullFeature(
          name: 'documents',
          maxPagesPerRun: 1,
          steps: [
            PaginatedListPullStep(
              key: 'list',
              pageSize: 2,
              handler: handler,
            ),
          ],
        ),
      );

    final coordinator = PullCoordinator(db: db, registry: registry);

    await coordinator.runFeature('documents');
    var checkpoint = await db.checkpointFor('documents', 'list');
    expect(checkpoint?.page, 2);
    expect(checkpoint?.status, PullStepStatus.inProgress);
    expect(handler.calls, 1);

    await coordinator.runFeature('documents');
    checkpoint = await db.checkpointFor('documents', 'list');
    expect(checkpoint?.status, PullStepStatus.complete);
    expect(checkpoint?.hasMore, false);
    expect(handler.calls, 2);
  });

  test('entity batch drains ids in batches', () async {
    final remaining = <String>{'1', '2', '3'};
    final batchHandler = _TrackingBatchHandler(remaining);

    final registry = PullFeatureRegistry()
      ..register(
        PullFeature(
          name: 'workflow',
          maxBatchesPerRun: 2,
          steps: [
            EntityBatchPullStep(
              key: 'detail',
              batchSize: 2,
              idSelector: (_) async => remaining.toList(),
              handler: batchHandler,
            ),
          ],
        ),
      );

    final coordinator = PullCoordinator(db: db, registry: registry);
    await coordinator.runFeature('workflow');

    expect(batchHandler.synced, {'1', '2', '3'});
    final checkpoint = await db.checkpointFor('workflow', 'detail');
    expect(checkpoint?.status, PullStepStatus.complete);
  });
}
