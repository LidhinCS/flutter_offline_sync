import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../models/cross_job_dependency.dart';

class _PendingStep {
  _PendingStep({
    required this.stepKey,
    required this.taskType,
    required this.input,
    required this.dependsOn,
    required this.externalDependsOn,
  });

  final String stepKey;
  final String taskType;
  final Map<String, dynamic> input;
  final List<String> dependsOn;
  final List<CrossJobDependency> externalDependsOn;
}

/// Builds a job with one or more dependent steps, then persists it in a
/// single transaction. Example:
///
/// ```dart
/// final parentJobId = await JobBuilder(db, feature: 'forms', screen: 'screen_x')
///   .addStep('submitX', taskType: 'submitX', input: {'name': name})
///   .enqueue();
///
/// final childJobId = await JobBuilder(db, feature: 'forms', screen: 'screen_y')
///   .addStep(
///     'submitY',
///     taskType: 'submitY',
///     input: {'title': title},
///     externalDependsOn: [
///       CrossJobDependency(
///         jobId: parentJobId,
///         stepKey: 'submitX',
///         mappings: [FieldMapping(from: 'id', to: 'parentId')],
///       ),
///     ],
///   )
///   .enqueue();
/// ```
class JobBuilder {
  JobBuilder(
    this._db, {
    required this.feature,
    required this.screen,
    Map<String, dynamic>? meta,
    String? idempotencyKey,
  })  : _meta = meta,
        _idempotencyKey = idempotencyKey ?? const Uuid().v4();

  final SyncDatabase _db;
  final String feature;
  final String screen;
  final Map<String, dynamic>? _meta;
  final String _idempotencyKey;
  final List<_PendingStep> _steps = [];

  JobBuilder addStep(
    String stepKey, {
    required String taskType,
    required Map<String, dynamic> input,
    List<String> dependsOn = const [],
    List<CrossJobDependency> externalDependsOn = const [],
  }) {
    if (_steps.any((s) => s.stepKey == stepKey)) {
      throw ArgumentError('Duplicate stepKey "$stepKey" in job builder.');
    }
    for (final dep in dependsOn) {
      if (!_steps.any((s) => s.stepKey == dep)) {
        throw ArgumentError(
          'Step "$stepKey" depends on "$dep", which must be added before it.',
        );
      }
    }
    _steps.add(_PendingStep(
      stepKey: stepKey,
      taskType: taskType,
      input: input,
      dependsOn: dependsOn,
      externalDependsOn: externalDependsOn,
    ));
    return this;
  }

  Future<int> enqueue() async {
    if (_steps.isEmpty) {
      throw StateError('Cannot enqueue a job with no steps.');
    }
    return _db.transaction(() async {
      final jobId = await _db.createJob(
        feature: feature,
        screen: screen,
        idempotencyKey: _idempotencyKey,
        meta: _meta,
      );
      for (var i = 0; i < _steps.length; i++) {
        final s = _steps[i];
        await _db.addStep(
          jobId: jobId,
          stepKey: s.stepKey,
          taskType: s.taskType,
          input: s.input,
          dependsOn: s.dependsOn,
          externalDependsOn: s.externalDependsOn,
          sortIndex: i,
        );
      }
      return jobId;
    });
  }
}
