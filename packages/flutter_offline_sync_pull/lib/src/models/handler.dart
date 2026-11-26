import 'package:meta/meta.dart';

/// Context passed to a [PullStepHandler] for one fetch attempt.
@immutable
class PullContext {
  const PullContext({
    required this.feature,
    required this.stepKey,
    required this.page,
    required this.pageSize,
    required this.entityIds,
  });

  final String feature;
  final String stepKey;

  /// Current page for [PaginatedListPullStep] (1-based).
  final int page;

  /// Page size for paginated steps.
  final int pageSize;

  /// Entity ids for [EntityBatchPullStep].
  final List<String> entityIds;
}

/// Outcome of one pull handler execution.
sealed class PullStepResult {
  const PullStepResult();

  const factory PullStepResult.success({bool hasMore}) = PullStepSuccess;
  const factory PullStepResult.failure(String message) = PullStepFailure;
}

final class PullStepSuccess extends PullStepResult {
  const PullStepSuccess({this.hasMore = false});
  final bool hasMore;
}

final class PullStepFailure extends PullStepResult {
  const PullStepFailure(this.message);
  final String message;
}

/// Fetches API data and persists into the app's Drift tables.
///
/// The pull package orchestrates checkpoints; handlers own HTTP + upsert logic.
abstract class PullStepHandler {
  const PullStepHandler();

  Future<PullStepResult> fetch(PullContext ctx);
}
