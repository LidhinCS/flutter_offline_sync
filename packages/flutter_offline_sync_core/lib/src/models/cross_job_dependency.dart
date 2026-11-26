import 'dart:convert';

import 'package:meta/meta.dart';

/// Maps one field from an upstream step's output into a downstream step's input.
///
/// Paths use dot notation for nested maps, e.g. `data.postId` or `body.parent.id`.
@immutable
class FieldMapping {
  const FieldMapping({
    required this.from,
    required this.to,
  });

  /// Dot path in the upstream step's success [output] map.
  final String from;

  /// Dot path in the downstream step's [input] map (written before the handler runs).
  final String to;

  Map<String, dynamic> toJson() => {'from': from, 'to': to};

  factory FieldMapping.fromJson(Map<String, dynamic> json) {
    return FieldMapping(
      from: json['from'] as String,
      to: json['to'] as String,
    );
  }
}

/// Declares that a step in this job must wait for another job's step to succeed
/// before it can run, and copies configured fields from that step's API output
/// into this step's input.
///
/// Use this when two forms live on different screens but the second API needs an
/// id (or other value) produced by the first — e.g. screen X submits a parent
/// record, screen Y updates a child that references the parent's server id.
///
/// Prefer [jobId] when the app already knows the upstream job id (typical when
/// the user submitted screen X before screen Y in the same session). Use
/// [screen] + [stepKey] to resolve the latest matching job at sync time.
@immutable
class CrossJobDependency {
  const CrossJobDependency({
    this.jobId,
    this.screen,
    this.feature,
    required this.stepKey,
    required this.mappings,
  }) : assert(
          jobId != null || screen != null,
          'Provide jobId or screen to identify the upstream job.',
        );

  /// Upstream job id, if known at enqueue time.
  final int? jobId;

  /// Screen of the upstream job when [jobId] is not set. The latest non-cancelled
  /// job on this screen with a step named [stepKey] is used.
  final String? screen;

  /// Optional extra filter when resolving by [screen].
  final String? feature;

  /// Step key within the upstream job whose [output] is read.
  final String stepKey;

  /// Fields to copy from upstream output into this step's input before execute().
  final List<FieldMapping> mappings;

  Map<String, dynamic> toJson() => {
        if (jobId != null) 'jobId': jobId,
        if (screen != null) 'screen': screen,
        if (feature != null) 'feature': feature,
        'stepKey': stepKey,
        'mappings': mappings.map((m) => m.toJson()).toList(),
      };

  factory CrossJobDependency.fromJson(Map<String, dynamic> json) {
    final rawMappings = json['mappings'] as List<dynamic>? ?? const [];
    return CrossJobDependency(
      jobId: json['jobId'] as int?,
      screen: json['screen'] as String?,
      feature: json['feature'] as String?,
      stepKey: json['stepKey'] as String,
      mappings: rawMappings
          .map((m) => FieldMapping.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

List<CrossJobDependency> parseCrossJobDependencies(String? json) {
  if (json == null || json.isEmpty) return const [];
  return (jsonDecode(json) as List<dynamic>)
      .map((e) => CrossJobDependency.fromJson(e as Map<String, dynamic>))
      .toList();
}
