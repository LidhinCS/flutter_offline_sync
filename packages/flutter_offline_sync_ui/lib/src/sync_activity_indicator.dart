import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_offline_sync_core/flutter_offline_sync_core.dart';

import 'sync_jobs_builder.dart';

/// Compact busy chip for foreground push/pull activity.
///
/// Provide [isPushing] / [isPulling] streams from [SyncEngine.isSyncingStream]
/// and `PullCoordinator.isPullingStream`. Optionally pass [db] + feature/screen
/// so jobs marked [JobStatus.running] (including background Workmanager) also
/// light up the indicator.
///
/// Placement and copy belong in the host app; this widget stays generic.
class SyncActivityIndicator extends StatefulWidget {
  const SyncActivityIndicator({
    super.key,
    this.isPushing,
    this.isPulling,
    this.initialPushing = false,
    this.initialPulling = false,
    this.db,
    this.feature,
    this.screen,
    this.pushingLabel = 'Uploading…',
    this.pullingLabel = 'Updating…',
    this.busyLabel = 'Syncing…',
    this.showWhenIdle = false,
  }) : assert(screen != null || feature != null || db == null);

  final Stream<bool>? isPushing;
  final Stream<bool>? isPulling;
  final bool initialPushing;
  final bool initialPulling;
  final SyncDatabase? db;
  final String? feature;
  final String? screen;
  final String pushingLabel;
  final String pullingLabel;
  final String busyLabel;
  final bool showWhenIdle;

  @override
  State<SyncActivityIndicator> createState() => _SyncActivityIndicatorState();
}

class _SyncActivityIndicatorState extends State<SyncActivityIndicator> {
  StreamSubscription<bool>? _pushSub;
  StreamSubscription<bool>? _pullSub;
  late bool _pushing;
  late bool _pulling;

  @override
  void initState() {
    super.initState();
    _pushing = widget.initialPushing;
    _pulling = widget.initialPulling;
    _pushSub = widget.isPushing?.listen((value) {
      if (!mounted) return;
      setState(() => _pushing = value);
    });
    _pullSub = widget.isPulling?.listen((value) {
      if (!mounted) return;
      setState(() => _pulling = value);
    });
  }

  @override
  void dispose() {
    unawaited(_pushSub?.cancel() ?? Future<void>.value());
    unawaited(_pullSub?.cancel() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = widget.db;
    if (db == null) {
      return _chip(context, hasRunningJobs: false);
    }

    return SyncJobsBuilder(
      db: db,
      feature: widget.feature,
      screen: widget.screen,
      builder: (context, jobs) {
        final hasRunning = jobs.any((j) => j.status == JobStatus.running);
        return _chip(context, hasRunningJobs: hasRunning);
      },
    );
  }

  Widget _chip(BuildContext context, {required bool hasRunningJobs}) {
    final busy = _pushing || _pulling || hasRunningJobs;
    if (!busy && !widget.showWhenIdle) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final label = !busy
        ? 'Up to date'
        : _pushing && !_pulling && !hasRunningJobs
        ? widget.pushingLabel
        : _pulling && !_pushing && !hasRunningJobs
        ? widget.pullingLabel
        : widget.busyLabel;

    return Chip(
      avatar: busy
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            )
          : Icon(
              Icons.cloud_done_outlined,
              size: 16,
              color: colorScheme.primary,
            ),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: colorScheme.outlineVariant),
    );
  }
}

/// Combined snapshot of push + pull busy flags (foreground isolate).
class SyncActivity {
  const SyncActivity({this.isPushing = false, this.isPulling = false});

  final bool isPushing;
  final bool isPulling;

  bool get isBusy => isPushing || isPulling;
}
