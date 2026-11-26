import 'package:drift/drift.dart';

import 'sync_jobs_table.dart';

/// A single handler invocation inside a job. Steps form a DAG via
/// [dependsOn]; the engine runs them in topological order.
class SyncSteps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get jobId => integer().references(SyncJobs, #id)();

  /// Unique within the job, e.g. "uploadImage". Referenced by dependsOn
  /// and used by downstream steps to look up this step's output.
  TextColumn get stepKey => text()();

  /// Registry key mapping to a registered [SyncTaskHandler].
  TextColumn get taskType => text()();

  /// JSON array of stepKeys this step depends on within the same job. Empty
  /// array = runnable immediately once cross-job deps are satisfied.
  TextColumn get dependsOn => text().withDefault(const Constant('[]'))();

  /// JSON array of [CrossJobDependency] objects — steps in other jobs/screens
  /// that must succeed first and whose outputs are mapped into this step's input.
  TextColumn get externalDependsOn =>
      text().withDefault(const Constant('[]'))();

  /// JSON: static input known at enqueue time (form fields, file paths...).
  TextColumn get input => text()();

  /// JSON: handler's result, populated after a successful run. Consumed by
  /// downstream steps via SyncContext.dependencyOutput(stepKey).
  TextColumn get output => text().nullable()();

  /// pending | running | success | failed | conflict | cancelled
  TextColumn get status => textEnum<StepStatus>()();

  TextColumn get lastError => text().nullable()();

  /// Present only when status == conflict; raw server state for the
  /// resolution UI to inspect.
  TextColumn get conflictData => text().nullable()();

  IntColumn get attempt => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Order hint for stable UI display / tie-breaking when multiple steps
  /// are simultaneously ready. Not used for correctness.
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();
}

enum StepStatus { pending, running, success, failed, conflict, cancelled }
