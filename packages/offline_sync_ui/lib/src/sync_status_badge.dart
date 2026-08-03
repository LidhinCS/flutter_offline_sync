import 'package:flutter/material.dart';
import 'package:offline_sync_core/offline_sync_core.dart';

import 'job_status_theme.dart';
import 'sync_job_utils.dart';
import 'sync_jobs_builder.dart';

/// Compact chip showing how many jobs are pending, syncing, or need attention.
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({
    required this.db,
    super.key,
    this.screen,
    this.feature,
    this.showWhenIdle = false,
  }) : assert(screen != null || feature != null);

  final SyncDatabase db;
  final String? screen;
  final String? feature;
  final bool showWhenIdle;

  @override
  Widget build(BuildContext context) {
    return SyncJobsBuilder(
      db: db,
      screen: screen,
      feature: feature,
      builder: (context, jobs) {
        final counts = countJobs(jobs);
        if (!showWhenIdle && !counts.hasActive && !counts.hasNeedsAttention) {
          return const SizedBox.shrink();
        }

        final colorScheme = Theme.of(context).colorScheme;
        final String label;
        final JobStatusAppearance appearance;

        if (counts.needsAttention > 0) {
          label = counts.conflict > 0
              ? '${counts.conflict} conflict${counts.conflict == 1 ? '' : 's'}'
              : '${counts.failed} failed';
          appearance = jobStatusAppearance(
            counts.conflict > 0 ? JobStatus.conflict : JobStatus.failed,
            colorScheme: colorScheme,
          );
        } else if (counts.running > 0) {
          label = '${counts.running} syncing';
          appearance = jobStatusAppearance(JobStatus.running, colorScheme: colorScheme);
        } else if (counts.pending > 0) {
          label = '${counts.pending} pending';
          appearance = jobStatusAppearance(JobStatus.pending, colorScheme: colorScheme);
        } else {
          label = 'Up to date';
          appearance = jobStatusAppearance(JobStatus.success, colorScheme: colorScheme);
        }

        return Chip(
          avatar: Icon(appearance.icon, size: 18, color: appearance.color),
          label: Text(label),
          visualDensity: VisualDensity.compact,
          side: BorderSide(color: appearance.color.withValues(alpha: 0.4)),
        );
      },
    );
  }
}
