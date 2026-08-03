import 'package:flutter/material.dart';
import 'package:offline_sync_core/offline_sync_core.dart';

import 'offline_sync_scope.dart';
import 'sync_job_list_tile.dart';
import 'sync_job_utils.dart';
import 'sync_jobs_builder.dart';

/// Banner for the top of a screen showing active sync jobs and quick actions.
class SyncScreenBanner extends StatelessWidget {
  const SyncScreenBanner({
    required this.screen,
    super.key,
    this.db,
    this.engine,
    this.onCancelPending,
  });

  final String screen;
  final SyncDatabase? db;
  final SyncEngine? engine;

  /// Called after pending jobs for this screen are cancelled.
  final VoidCallback? onCancelPending;

  @override
  Widget build(BuildContext context) {
    final scope = OfflineSyncScope.maybeOf(context);
    final resolvedDb = db ?? scope?.db;
    final resolvedEngine = engine ?? scope?.engine;

    assert(
      resolvedDb != null && resolvedEngine != null,
      'Provide db and engine, or wrap with OfflineSyncScope.',
    );

    return SyncJobsBuilder(
      db: resolvedDb!,
      screen: screen,
      builder: (context, jobs) {
        final visible = activeJobs(jobs);
        if (visible.isEmpty) return const SizedBox.shrink();

        final counts = countJobs(visible);
        final colorScheme = Theme.of(context).colorScheme;
        final message = _bannerMessage(counts);
        final accentColor =
            counts.hasNeedsAttention ? colorScheme.error : colorScheme.primary;

        return Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          color: accentColor.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      counts.hasNeedsAttention
                          ? Icons.warning_amber_outlined
                          : Icons.cloud_upload_outlined,
                      color: accentColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(message)),
                    if (counts.pending > 0)
                      TextButton(
                        onPressed: () async {
                          await resolvedEngine!.cancelJobsForScreen(screen);
                          onCancelPending?.call();
                        },
                        child: const Text('Discard'),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                ...visible.map(
                  (job) => SyncJobListTile(
                    job: job,
                    engine: resolvedEngine!,
                    dense: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _bannerMessage(SyncJobCounts counts) {
    if (counts.conflict > 0) {
      return '${counts.conflict} job${counts.conflict == 1 ? '' : 's'} need conflict resolution';
    }
    if (counts.failed > 0) {
      return '${counts.failed} job${counts.failed == 1 ? '' : 's'} failed to sync';
    }
    if (counts.running > 0) {
      return 'Syncing ${counts.running} job${counts.running == 1 ? '' : 's'}...';
    }
    return '${counts.pending} job${counts.pending == 1 ? '' : 's'} waiting to sync';
  }
}
