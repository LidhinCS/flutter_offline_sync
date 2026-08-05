import 'package:offline_sync_pull/offline_sync_pull.dart';

import 'connectivity_pull_trigger.dart';

/// Starts connectivity-triggered foreground pulls for all registered features.
class FlutterPullCoordinator {
  FlutterPullCoordinator({required this.coordinator});

  final PullCoordinator coordinator;
  ConnectivityPullTrigger? _connectivityTrigger;

  Future<void> startForegroundPull() async {
    _connectivityTrigger ??= ConnectivityPullTrigger(coordinator)..start();
  }

  Future<void> stopForegroundPull() =>
      _connectivityTrigger?.stop() ?? Future.value();
}
