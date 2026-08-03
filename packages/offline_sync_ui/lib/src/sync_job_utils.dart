import 'dart:convert';

import 'package:offline_sync_core/offline_sync_core.dart';

/// Counts of jobs grouped by [JobStatus].
class SyncJobCounts {
  const SyncJobCounts({
    this.pending = 0,
    this.running = 0,
    this.failed = 0,
    this.conflict = 0,
    this.success = 0,
    this.cancelled = 0,
  });

  final int pending;
  final int running;
  final int failed;
  final int conflict;
  final int success;
  final int cancelled;

  int get active => pending + running;

  int get needsAttention => failed + conflict;

  bool get hasActive => active > 0;

  bool get hasNeedsAttention => needsAttention > 0;
}

SyncJobCounts countJobs(Iterable<SyncJob> jobs) {
  var pending = 0;
  var running = 0;
  var failed = 0;
  var conflict = 0;
  var success = 0;
  var cancelled = 0;

  for (final job in jobs) {
    switch (job.status) {
      case JobStatus.pending:
        pending++;
      case JobStatus.running:
        running++;
      case JobStatus.failed:
        failed++;
      case JobStatus.conflict:
        conflict++;
      case JobStatus.success:
        success++;
      case JobStatus.cancelled:
        cancelled++;
    }
  }

  return SyncJobCounts(
    pending: pending,
    running: running,
    failed: failed,
    conflict: conflict,
    success: success,
    cancelled: cancelled,
  );
}

/// Reads an optional display label from a job's JSON [SyncJob.meta] field.
String jobDisplayLabel(SyncJob job, {String fallback = 'Sync job'}) {
  final raw = job.meta;
  if (raw == null || raw.isEmpty) return fallback;

  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      final label = decoded['label'];
      if (label is String && label.isNotEmpty) return label;
    }
  } on FormatException {
    // Fall through to fallback.
  }

  return fallback;
}

/// Filters out completed/cancelled jobs — useful for status UI.
List<SyncJob> activeJobs(Iterable<SyncJob> jobs) {
  return jobs
      .where(
        (job) =>
            job.status != JobStatus.success &&
            job.status != JobStatus.cancelled,
      )
      .toList();
}
