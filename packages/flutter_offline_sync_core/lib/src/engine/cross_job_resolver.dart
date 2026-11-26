import 'dart:convert';

import '../db/database.dart';
import '../db/sync_jobs_table.dart' show JobStatus;
import '../db/sync_steps_table.dart' show StepStatus;
import '../models/cross_job_dependency.dart';
import 'field_path.dart';

/// Cross-job dependency state for a single step.
enum CrossJobReadiness {
  /// Upstream succeeded; mappings can be applied.
  ready,

  /// Upstream still pending/running or not found yet.
  waiting,

  /// Upstream job/step failed or conflicted; this step cannot proceed.
  blocked,
}

/// Resolves [CrossJobDependency] links against the database.
class CrossJobResolver {
  CrossJobResolver(this._db);

  final SyncDatabase _db;

  Future<CrossJobReadiness> readinessForStep(SyncStep step) async {
    final deps = parseCrossJobDependencies(step.externalDependsOn);
    if (deps.isEmpty) return CrossJobReadiness.ready;

    for (final dep in deps) {
      final upstream = await _db.resolveCrossJobUpstreamStep(dep);
      if (upstream == null) {
        return CrossJobReadiness.waiting;
      }

      final upstreamJob = await _db.jobById(upstream.jobId);
      if (upstreamJob == null) {
        return CrossJobReadiness.waiting;
      }

      if (upstreamJob.status == JobStatus.failed ||
          upstreamJob.status == JobStatus.conflict) {
        return CrossJobReadiness.blocked;
      }

      if (upstream.status == StepStatus.failed ||
          upstream.status == StepStatus.conflict) {
        return CrossJobReadiness.blocked;
      }

      if (upstream.status != StepStatus.success || upstream.output == null) {
        return CrossJobReadiness.waiting;
      }
    }
    return CrossJobReadiness.ready;
  }

  /// Whether a pending job can be started: not blocked and at least one step
  /// could run (internal + cross-job deps satisfied).
  Future<bool> isJobRunnable(SyncJob job) async {
    if (job.status != JobStatus.pending) return false;

    final steps = await _db.stepsForJob(job.id);
    final byKey = {for (final s in steps) s.stepKey: s};

    var hasWaitingStep = false;
    for (final step in steps) {
      if (step.status != StepStatus.pending) continue;

      final crossJob = await readinessForStep(step);
      if (crossJob == CrossJobReadiness.blocked) return false;
      if (crossJob == CrossJobReadiness.waiting) {
        hasWaitingStep = true;
        continue;
      }

      final internalDeps =
          (jsonDecode(step.dependsOn) as List).cast<String>();
      final internalReady = internalDeps.every(
        (dep) => byKey[dep]?.status == StepStatus.success,
      );
      if (internalReady) return true;
      hasWaitingStep = true;
    }

    return !hasWaitingStep && steps.any((s) => s.status == StepStatus.pending);
  }

  Future<Map<String, dynamic>> resolvedInput(SyncStep step) async {
    final input = jsonDecode(step.input) as Map<String, dynamic>;
    final deps = parseCrossJobDependencies(step.externalDependsOn);
    if (deps.isEmpty) return input;

    var result = Map<String, dynamic>.from(input);
    for (final dep in deps) {
      final upstream = await _db.resolveCrossJobUpstreamStep(dep);
      if (upstream == null || upstream.output == null) {
        throw StateError(
          'Upstream step "${dep.stepKey}" is not ready for cross-job mapping.',
        );
      }
      final output = jsonDecode(upstream.output!) as Map<String, dynamic>;
      result = FieldPath.applyMappings(result, output, dep.mappings);
    }
    return result;
  }
}
