import 'package:flutter/widgets.dart';
import 'package:offline_sync_core/offline_sync_core.dart';

/// Rebuilds when jobs for a [screen] or [feature] change in [SyncDatabase].
class SyncJobsBuilder extends StatelessWidget {
  const SyncJobsBuilder({
    required this.db,
    required this.builder,
    super.key,
    this.screen,
    this.feature,
  }) : assert(
          screen != null || feature != null,
          'Provide either screen or feature.',
        );

  final SyncDatabase db;
  final String? screen;
  final String? feature;
  final Widget Function(BuildContext context, List<SyncJob> jobs) builder;

  @override
  Widget build(BuildContext context) {
    final stream = screen != null
        ? db.watchJobsForScreen(screen!)
        : db.watchJobsForFeature(feature!);

    return StreamBuilder<List<SyncJob>>(
      stream: stream,
      builder: (context, snapshot) {
        return builder(context, snapshot.data ?? const []);
      },
    );
  }
}
