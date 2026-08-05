import 'handler.dart';

/// Kind of pull work for a single step in a feature.
sealed class PullStep {
  const PullStep({
    required this.key,
    this.dependsOn = const [],
  });

  final String key;
  final List<String> dependsOn;
}

/// Paginated list sync: page 1, 2, 3… until [PullStepHandler] reports no more data.
class PaginatedListPullStep extends PullStep {
  const PaginatedListPullStep({
    required super.key,
    required this.pageSize,
    required this.handler,
    super.dependsOn,
  });

  final int pageSize;
  final PullStepHandler handler;
}

/// Drains a batch of entity ids (e.g. workflow details missing locally).
typedef EntityIdSelector = Future<List<String>> Function(PullContext ctx);

class EntityBatchPullStep extends PullStep {
  const EntityBatchPullStep({
    required super.key,
    required this.batchSize,
    required this.idSelector,
    required this.handler,
    super.dependsOn,
  });

  final int batchSize;
  final EntityIdSelector idSelector;
  final PullStepHandler handler;
}
