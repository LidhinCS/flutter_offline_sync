import 'package:material_ui/material_ui.dart';
import 'package:flutter_offline_sync_core/flutter_offline_sync_core.dart';

import 'job_status_theme.dart';
import 'sync_job_utils.dart';

/// A list tile for one [SyncJob] with retry support for failed jobs.
///
/// Display conventions for [SyncJob.meta] (all optional):
/// - `label` — primary title (defaults to "Sync job")
/// - `subtitle` — secondary record line (e.g. document title / id)
class SyncJobListTile extends StatelessWidget {
  const SyncJobListTile({
    required this.job,
    required this.engine,
    super.key,
    this.dense = false,
    this.onRetried,
    this.onConflictTap,
  });

  final SyncJob job;
  final SyncEngine engine;
  final bool dense;
  final VoidCallback? onRetried;
  final VoidCallback? onConflictTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appearance = jobStatusAppearance(
      job.status,
      colorScheme: colorScheme,
    );
    final statusText = switch (job.status) {
      JobStatus.pending => 'Waiting for connectivity',
      JobStatus.running => 'Sync in progress',
      JobStatus.failed => 'Tap retry to try again',
      JobStatus.conflict => 'Needs your attention',
      JobStatus.success => 'Synced successfully',
      JobStatus.cancelled => 'Cancelled',
    };
    final detail = jobDisplaySubtitle(job);

    return ListTile(
      dense: dense,
      leading: Icon(appearance.icon, color: appearance.color),
      title: Text(jobDisplayLabel(job)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail != null) ...[
            Text(
              detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          Text(
            statusText,
            style: textTheme.bodySmall?.copyWith(color: appearance.color),
          ),
        ],
      ),
      isThreeLine: detail != null,
      trailing: _trailing(context),
      onTap: job.status == JobStatus.conflict ? onConflictTap : null,
    );
  }

  Widget? _trailing(BuildContext context) {
    return switch (job.status) {
      JobStatus.failed => TextButton(
        onPressed: () async {
          await engine.retryJob(job.id);
          onRetried?.call();
        },
        child: const Text('Retry'),
      ),
      JobStatus.conflict => const Icon(Icons.chevron_right),
      _ => null,
    };
  }
}
