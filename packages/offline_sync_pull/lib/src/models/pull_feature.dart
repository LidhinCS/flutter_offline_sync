import 'pull_step.dart';

/// A feature (e.g. documents, workflow) made of ordered pull steps.
class PullFeature {
  const PullFeature({
    required this.name,
    required this.steps,
    this.maxPagesPerRun = 5,
    this.maxBatchesPerRun = 3,
  });

  final String name;
  final List<PullStep> steps;

  /// Safety cap for paginated steps in a single coordinator run.
  final int maxPagesPerRun;

  /// Safety cap for entity-batch steps in a single coordinator run.
  final int maxBatchesPerRun;
}

/// Registry of pull features keyed by [PullFeature.name].
class PullFeatureRegistry {
  final Map<String, PullFeature> _features = {};

  void register(PullFeature feature) {
    _features[feature.name] = feature;
  }

  PullFeature resolve(String name) {
    final feature = _features[name];
    if (feature == null) {
      throw StateError('No pull feature registered for "$name".');
    }
    return feature;
  }

  Iterable<PullFeature> get all => _features.values;
}
