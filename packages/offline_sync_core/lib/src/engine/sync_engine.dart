import 'dart:convert';

import 'package:offline_sync_core/src/db/sync_jobs_table.dart' show JobStatus;
import 'package:offline_sync_core/offline_sync_core.dart' show StepStatus;

import '../db/database.dart';
import '../models/handler.dart';
import 'cross_job_resolver.dart';
import 'retry_policy.dart';

/// Orchestrates execution of a job's step DAG: resolves dependency order,
/// runs ready steps, persists outputs, and stops at the first failed or
/// conflicted step without touching its unresolved downstream siblings.
///
/// This is deliberately the only place that understands job/step status
/// transitions -- handlers just do work and return a result.
class SyncEngine {
  SyncEngine({
    required SyncDatabase db,
    required SyncHandlerRegistry registry,
    RetryPolicy retryPolicy = const RetryPolicy(),
  })  : _db = db,
        _registry = registry,
        _retryPolicy = retryPolicy,
        _crossJob = CrossJobResolver(db);

  final SyncDatabase _db;
  final SyncHandlerRegistry _registry;
  final RetryPolicy _retryPolicy;
  final CrossJobResolver _crossJob;

  // In-process coalescing state (per SyncEngine instance / isolate). This is
  // separate from the cross-isolate DB lock: the DB lock stops two isolates
  // from running the same job at once, but on its own a syncAll() call that
  // arrives while another is already draining would just bail out silently
  // and its trigger (e.g. "connectivity just returned") would be lost. Instead
  // we remember that another pass was requested and run one more drain after
  // the current one finishes.
  bool _draining = false;
  bool _rerunRequested = false;

  /// Runs every pending job to completion, then loops again if another
  /// syncAll() call arrived while this one was in progress. Call this from
  /// your connectivity listener and from the WorkManager background
  /// callback -- concurrent calls within the same isolate coalesce rather
  /// than running in parallel or getting dropped; concurrent calls across
  /// isolates are serialized by the DB-level lock.
  ///
  /// Jobs on different screens that are linked via [CrossJobDependency] are
  /// ordered automatically: the upstream screen's job syncs first so ids from
  /// its API response can be mapped into the dependent job's input.
  Future<void> syncAll({Duration lockTtl = const Duration(minutes: 5)}) async {
    if (_draining) {
      _rerunRequested = true;
      return;
    }
    _draining = true;
    try {
      do {
        _rerunRequested = false;
        final acquired = await _db.tryAcquireLock(ttl: lockTtl);
        if (!acquired) return; // another isolate/process is already syncing
        try {
          await recoverInterruptedWork();
          await _syncPendingJobs();
        } finally {
          await _db.releaseLock();
        }
      } while (_rerunRequested);
    } finally {
      _draining = false;
    }
  }

  Future<void> _syncPendingJobs() async {
    while (true) {
      final pending = await _db.pendingJobs();
      if (pending.isEmpty) return;

      final runnable = <SyncJob>[];
      for (final job in pending) {
        if (await _crossJob.isJobRunnable(job)) {
          runnable.add(job);
        }
      }
      if (runnable.isEmpty) return;

      runnable.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      for (final job in runnable) {
        await runJob(job.id);
      }
    }
  }

  /// Resets anything left in `running` back to `pending`. A step/job only
  /// stays `running` while a live runJob() call is actively awaiting it --
  /// if one is found at startup, the app or isolate that set it was killed
  /// mid-execution, not genuinely still working. Called automatically at
  /// the start of every syncAll() pass; safe to call directly too (e.g.
  /// once at app startup before the first real sync trigger).
  Future<void> recoverInterruptedWork() async {
    final stuckSteps = await _db.runningSteps();
    for (final step in stuckSteps) {
      await _db.resetStepToPending(step.id);
    }
    final stuckJobs = await _db.runningJobs();
    for (final job in stuckJobs) {
      await _db.markJobStatus(job.id, JobStatus.pending);
    }
  }

  /// Runs (or resumes) a single job to completion or until it blocks on a
  /// failed/conflicted step.
  Future<void> runJob(int jobId) async {
    if (!await _crossJob.isJobRunnable(await _jobOrThrow(jobId))) {
      return;
    }

    await _db.markJobStatus(jobId, JobStatus.running);

    while (true) {
      final steps = await _db.stepsForJob(jobId);

      if (steps.every((s) => s.status == StepStatus.success)) {
        await _db.markJobStatus(jobId, JobStatus.success);
        return;
      }

      if (steps.any((s) => s.status == StepStatus.conflict)) {
        await _db.markJobStatus(jobId, JobStatus.conflict);
        return; // halt -- needs SyncEngine.resolveConflict
      }

      if (steps.any((s) => s.status == StepStatus.failed)) {
        await _db.markJobStatus(jobId, JobStatus.failed);
        return; // halt -- needs retryJob (partial retry) or cancellation
      }

      final byKey = {for (final s in steps) s.stepKey: s};

      final ready = <SyncStep>[];
      var blocked = false;
      for (final s in steps) {
        if (s.status != StepStatus.pending) continue;

        final crossJob = await _crossJob.readinessForStep(s);
        if (crossJob == CrossJobReadiness.blocked) {
          blocked = true;
          continue;
        }
        if (crossJob != CrossJobReadiness.ready) continue;

        final deps = (jsonDecode(s.dependsOn) as List).cast<String>();
        if (!deps.every((dep) => byKey[dep]?.status == StepStatus.success)) {
          continue;
        }
        ready.add(s);
      }

      if (blocked && ready.isEmpty) {
        for (final s in steps.where((s) => s.status == StepStatus.pending)) {
          await _db.markStepFailed(
            s.id,
            'Blocked: an upstream job failed or has a conflict.',
          );
        }
        await _db.markJobStatus(jobId, JobStatus.failed);
        return;
      }

      if (ready.isEmpty) {
        await _db.markJobStatus(jobId, JobStatus.pending);
        return;
      }

      await Future.wait(ready.map((s) => _runStep(jobId, s, byKey)));
    }
  }

  Future<SyncJob> _jobOrThrow(int jobId) async {
    final job = await _db.jobById(jobId);
    if (job == null) {
      throw StateError('No job with id $jobId.');
    }
    return job;
  }

  Future<void> _runStep(
      int jobId, SyncStep step, Map<String, SyncStep> byKey) async {
    await _db.markStepRunning(step.id);

    final deps = (jsonDecode(step.dependsOn) as List).cast<String>();
    final dependencyOutputs = <String, Map<String, dynamic>>{};
    for (final dep in deps) {
      final depStep = byKey[dep]!;
      dependencyOutputs[dep] =
          jsonDecode(depStep.output!) as Map<String, dynamic>;
    }

    final job = await (_db.select(_db.syncJobs)
          ..where((j) => j.id.equals(jobId)))
        .getSingle();

    final resolvedInput = await _crossJob.resolvedInput(step);

    final ctx = SyncContext(
      input: resolvedInput,
      dependencyOutputs: dependencyOutputs,
      idempotencyKey: job.idempotencyKey,
    );

    final handler = _registry.resolve(step.taskType);

    try {
      final result = await handler.execute(ctx);
      switch (result) {
        case SyncStepSuccess(:final output):
          await _db.markStepSuccess(step.id, output);
        case SyncStepConflict(:final serverState):
          await _db.markStepConflict(step.id, serverState);
        case SyncStepFailure(:final error, :final retryable):
          await _handleFailure(step, error, retryable);
      }
    } catch (e) {
      await _handleFailure(step, e.toString(), true);
    }
  }

  Future<void> _handleFailure(
      SyncStep step, String error, bool retryable) async {
    final nextAttempt = step.attempt + 1;
    if (retryable && _retryPolicy.shouldRetry(nextAttempt)) {
      final delay = _retryPolicy.delayFor(nextAttempt);
      await _db.bumpAttempt(step.id, nextAttempt, DateTime.now().add(delay));
    }
    await _db.markStepFailed(step.id, error);
  }

  /// Resumes a job after failure: resets failed steps to pending (and any
  /// previously-successful step whose handler says its output is now
  /// stale), then re-runs. Steps that already succeeded and remain valid
  /// are NOT re-executed -- this is the partial retry.
  Future<void> retryJob(int jobId) async {
    final steps = await _db.stepsForJob(jobId);

    for (final step in steps) {
      if (step.status == StepStatus.failed) {
        await _db.resetStepToPending(step.id);
        continue;
      }
      if (step.status == StepStatus.success) {
        final handler = _registry.resolve(step.taskType);
        final output = jsonDecode(step.output!) as Map<String, dynamic>;
        final stillValid =
            handler.isOutputStillValid(output, step.completedAt!);
        if (!stillValid) {
          await _db.resetStepToPending(step.id);
        }
      }
    }

    await _db.markJobStatus(jobId, JobStatus.pending);
    await runJob(jobId);
  }

  /// Call after the user/app resolves a conflicted step (e.g. chooses
  /// "overwrite server" or "keep server version"). [resolution] should be
  /// whatever output the resolution implies -- it's stored as the step's
  /// success output as if the handler had produced it directly.
  Future<void> resolveConflict(
    int jobId,
    String stepKey,
    Map<String, dynamic> resolution,
  ) async {
    final steps = await _db.stepsForJob(jobId);
    final step = steps.firstWhere((s) => s.stepKey == stepKey);
    await _db.markStepSuccess(step.id, resolution);
    await _db.markJobStatus(jobId, JobStatus.pending);
    await runJob(jobId);
  }

  /// Cancels every pending job for a screen -- e.g. the user discarded a
  /// draft before it finished syncing.
  Future<void> cancelJobsForScreen(String screen) =>
      _db.cancelJobsForScreen(screen);
}
