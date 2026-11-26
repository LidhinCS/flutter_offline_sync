import 'package:flutter_offline_sync_core/flutter_offline_sync_core.dart';

import 'connectivity_sync_trigger.dart';

/// Wires up foreground sync: recovers interrupted work at startup and
/// triggers [SyncEngine.syncAll] when connectivity returns.
class FlutterSyncCoordinator {
  FlutterSyncCoordinator({required this.engine});

  final SyncEngine engine;
  ConnectivitySyncTrigger? _connectivityTrigger;

  /// Resets jobs/steps stuck in `running` after a previous kill mid-sync,
  /// starts the connectivity listener (which also probes current online
  /// state), and drains any pending / retryable-failed outbox jobs.
  Future<void> startForegroundSync() async {
    await engine.recoverInterruptedWork();
    _connectivityTrigger ??= ConnectivitySyncTrigger(engine)..start();
    // Connectivity trigger syncs when already online, but also drain here so
    // callers that inject a test trigger without a live Connectivity still
    // get a startup pass.
    await engine.syncAll();
  }

  /// Stops the connectivity listener. Does not cancel background Workmanager
  /// tasks — use [cancelBackgroundSync] for that.
  Future<void> stopForegroundSync() =>
      _connectivityTrigger?.stop() ?? Future.value();
}
