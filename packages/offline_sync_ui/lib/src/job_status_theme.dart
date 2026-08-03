import 'package:flutter/material.dart';
import 'package:offline_sync_core/offline_sync_core.dart';

/// Visual styling for a [JobStatus].
class JobStatusAppearance {
  const JobStatusAppearance({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

JobStatusAppearance jobStatusAppearance(
  JobStatus status, {
  required ColorScheme colorScheme,
}) {
  return switch (status) {
    JobStatus.pending => JobStatusAppearance(
        label: 'Pending',
        icon: Icons.schedule_outlined,
        color: colorScheme.tertiary,
      ),
    JobStatus.running => JobStatusAppearance(
        label: 'Syncing',
        icon: Icons.sync,
        color: colorScheme.primary,
      ),
    JobStatus.success => JobStatusAppearance(
        label: 'Synced',
        icon: Icons.check_circle_outline,
        color: colorScheme.primary,
      ),
    JobStatus.failed => JobStatusAppearance(
        label: 'Failed',
        icon: Icons.error_outline,
        color: colorScheme.error,
      ),
    JobStatus.conflict => JobStatusAppearance(
        label: 'Conflict',
        icon: Icons.warning_amber_outlined,
        color: colorScheme.error,
      ),
    JobStatus.cancelled => JobStatusAppearance(
        label: 'Cancelled',
        icon: Icons.cancel_outlined,
        color: colorScheme.outline,
      ),
  };
}
