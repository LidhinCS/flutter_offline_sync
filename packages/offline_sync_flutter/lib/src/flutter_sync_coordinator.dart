import 'package:offline_sync_core/offline_sync_core.dart';

import 'connectivity_sync_trigger.dart';

/// Wires up foreground sync: recovers interrupted work at startup and
/// triggers [SyncEngine.syncAll] when connectivity returns.
class FlutterSyncCoordinator {
  FlutterSyncCoordinator({required this.engine});

  final SyncEngine engine;
  ConnectivitySyncTrigger? _connectivityTrigger;

  /// Resets jobs/steps stuck in `running` after a previous kill mid-sync, then
  /// starts the connectivity listener.
  Future<void> startForegroundSync() async {
    await engine.recoverInterruptedWork();
    _connectivityTrigger ??= ConnectivitySyncTrigger(engine)..start();
  }

  /// Stops the connectivity listener. Does not cancel background Workmanager
  /// tasks — use [cancelBackgroundSync] for that.
  Future<void> stopForegroundSync() => _connectivityTrigger?.stop() ?? Future.value();
}
