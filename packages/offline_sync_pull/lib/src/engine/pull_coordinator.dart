import '../db/database.dart';
import '../db/pull_checkpoints_table.dart';
import '../models/handler.dart';
import '../models/pull_feature.dart';
import '../models/pull_step.dart';

/// Runs registered [PullFeature] steps: paginated lists and entity batches.
class PullCoordinator {
  PullCoordinator({
    required PullDatabase db,
    required PullFeatureRegistry registry,
  })  : _db = db,
        _registry = registry;

  final PullDatabase _db;
  final PullFeatureRegistry _registry;

  /// Runs every registered feature.
  Future<void> runAll() async {
    for (final feature in _registry.all) {
      await runFeature(feature.name);
    }
  }

  /// Runs all steps for one feature (bounded by per-feature caps).
  Future<void> runFeature(String featureName) async {
    final feature = _registry.resolve(featureName);
    for (final step in feature.steps) {
      if (!await _dependenciesMet(feature, step)) continue;

      switch (step) {
        case PaginatedListPullStep():
          await _runPaginated(feature, step);
        case EntityBatchPullStep():
          await _runEntityBatch(feature, step);
      }
    }
  }

  Future<bool> _dependenciesMet(PullFeature feature, PullStep step) async {
    for (final dep in step.dependsOn) {
      final checkpoint = await _db.checkpointFor(feature.name, dep);
      if (checkpoint == null || checkpoint.status != PullStepStatus.complete) {
        return false;
      }
    }
    return true;
  }

  Future<void> _runPaginated(
    PullFeature feature,
    PaginatedListPullStep step,
  ) async {
    var checkpoint = await _db.checkpointFor(feature.name, step.key);
    checkpoint ??= await _insertInitialCheckpoint(
      feature.name,
      step.key,
      step.pageSize,
    );

    if (checkpoint.status == PullStepStatus.complete && !checkpoint.hasMore) {
      return;
    }

    var page = checkpoint.page;
    var hasMore = checkpoint.hasMore;
    var pagesRun = 0;

    while (hasMore && pagesRun < feature.maxPagesPerRun) {
      final ctx = PullContext(
        feature: feature.name,
        stepKey: step.key,
        page: page,
        pageSize: step.pageSize,
        entityIds: const [],
      );

      final result = await step.handler.fetch(ctx);
      if (result is PullStepFailure) {
        await _db.upsertCheckpoint(
          feature: feature.name,
          stepKey: step.key,
          page: page,
          pageSize: step.pageSize,
          status: PullStepStatus.pending,
          hasMore: hasMore,
          lastError: result.message,
        );
        return;
      }

      final success = result as PullStepSuccess;
      hasMore = success.hasMore;
      if (hasMore) {
        page++;
      }
      pagesRun++;
    }

    await _db.upsertCheckpoint(
      feature: feature.name,
      stepKey: step.key,
      page: page,
      pageSize: step.pageSize,
      status: hasMore ? PullStepStatus.inProgress : PullStepStatus.complete,
      hasMore: hasMore,
    );
  }

  Future<void> _runEntityBatch(
    PullFeature feature,
    EntityBatchPullStep step,
  ) async {
    var batchesRun = 0;

    while (batchesRun < feature.maxBatchesPerRun) {
      final probeCtx = PullContext(
        feature: feature.name,
        stepKey: step.key,
        page: 1,
        pageSize: step.batchSize,
        entityIds: const [],
      );

      final ids = await step.idSelector(probeCtx);
      if (ids.isEmpty) {
        await _db.upsertCheckpoint(
          feature: feature.name,
          stepKey: step.key,
          page: 1,
          pageSize: step.batchSize,
          status: PullStepStatus.complete,
          hasMore: false,
        );
        return;
      }

      final batch = ids.take(step.batchSize).toList();
      final ctx = PullContext(
        feature: feature.name,
        stepKey: step.key,
        page: 1,
        pageSize: step.batchSize,
        entityIds: batch,
      );

      final result = await step.handler.fetch(ctx);
      if (result is PullStepFailure) {
        await _db.upsertCheckpoint(
          feature: feature.name,
          stepKey: step.key,
          page: 1,
          pageSize: step.batchSize,
          status: PullStepStatus.pending,
          hasMore: true,
          lastError: result.message,
        );
        return;
      }

      batchesRun++;

      final remaining = await step.idSelector(probeCtx);
      if (remaining.isEmpty) {
        await _db.upsertCheckpoint(
          feature: feature.name,
          stepKey: step.key,
          page: 1,
          pageSize: step.batchSize,
          status: PullStepStatus.complete,
          hasMore: false,
        );
        return;
      }
    }

    await _db.upsertCheckpoint(
      feature: feature.name,
      stepKey: step.key,
      page: 1,
      pageSize: step.batchSize,
      status: PullStepStatus.inProgress,
      hasMore: true,
    );
  }

  Future<PullCheckpoint> _insertInitialCheckpoint(
    String feature,
    String stepKey,
    int pageSize,
  ) async {
    await _db.upsertCheckpoint(
      feature: feature,
      stepKey: stepKey,
      page: 1,
      pageSize: pageSize,
      status: PullStepStatus.pending,
      hasMore: true,
    );
    final row = await _db.checkpointFor(feature, stepKey);
    return row!;
  }
}
