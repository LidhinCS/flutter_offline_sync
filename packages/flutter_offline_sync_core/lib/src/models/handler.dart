import 'package:meta/meta.dart';

/// Data made available to a handler when its step runs: the step's own
/// static input, plus outputs of every step it depends on (already
/// resolved by the engine before execute() is called).
@immutable
class SyncContext {
  const SyncContext({
    required this.input,
    required this.dependencyOutputs,
    required this.idempotencyKey,
  });

  /// Static params stored at enqueue time (form fields, file paths, ids).
  final Map<String, dynamic> input;

  /// stepKey -> that step's output map, for every dependency.
  final Map<String, Map<String, dynamic>> dependencyOutputs;

  /// Stable per-job key; pass as an Idempotency-Key style header so a
  /// retried request after a partial failure doesn't create duplicates
  /// server-side.
  final String idempotencyKey;

  /// Convenience accessor: output of a specific upstream step.
  Map<String, dynamic> dependencyOutput(String stepKey) {
    final out = dependencyOutputs[stepKey];
    if (out == null) {
      throw StateError(
        'No output found for dependency "$stepKey". '
        'Check that it is listed in dependsOn and completed successfully '
        'before this step runs.',
      );
    }
    return out;
  }
}

/// Outcome of a single handler execution.
sealed class SyncStepResult {
  const SyncStepResult();

  const factory SyncStepResult.success(Map<String, dynamic> output) = SyncStepSuccess;
  const factory SyncStepResult.failure(String error, {bool retryable}) = SyncStepFailure;
  const factory SyncStepResult.conflict(Map<String, dynamic> serverState) = SyncStepConflict;
}

final class SyncStepSuccess extends SyncStepResult {
  const SyncStepSuccess(this.output);
  final Map<String, dynamic> output;
}

final class SyncStepFailure extends SyncStepResult {
  const SyncStepFailure(this.error, {this.retryable = true});
  final String error;

  /// If false, the engine marks the step failed but will NOT retry it
  /// automatically on the next sync pass (e.g. a 4xx validation error that
  /// will never succeed without user intervention). Manual retry via
  /// [SyncEngine.retryJob] still works.
  final bool retryable;
}

final class SyncStepConflict extends SyncStepResult {
  const SyncStepConflict(this.serverState);
  final Map<String, dynamic> serverState;
}

/// Implement one of these per distinct API operation and register it by
/// [taskType] key. The engine never inspects HTTP details directly -- it
/// only calls execute() and stores whatever comes back.
abstract class SyncTaskHandler {
  const SyncTaskHandler();

  Future<SyncStepResult> execute(SyncContext ctx);

  /// Called before reusing a previously-successful step's output during a
  /// retry of a sibling/downstream step. Return false to force
  /// re-execution even though this step already succeeded (e.g. a
  /// presigned upload URL that expires). Defaults to always reusable,
  /// which is correct for durable outputs like a permanent imageUrl or a
  /// server-assigned id.
  bool isOutputStillValid(Map<String, dynamic> output, DateTime completedAt) => true;
}

/// Simple in-memory registry mapping taskType -> handler. Register your
/// handlers once at app startup (and again inside the background isolate
/// entrypoint, since it has no shared state with the foreground app).
class SyncHandlerRegistry {
  final Map<String, SyncTaskHandler> _handlers = {};

  void register(String taskType, SyncTaskHandler handler) {
    _handlers[taskType] = handler;
  }

  SyncTaskHandler resolve(String taskType) {
    final handler = _handlers[taskType];
    if (handler == null) {
      throw StateError(
        'No handler registered for taskType "$taskType". '
        'Did you forget to register it in the background isolate entrypoint?',
      );
    }
    return handler;
  }
}
