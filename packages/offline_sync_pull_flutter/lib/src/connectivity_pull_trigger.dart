import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:offline_sync_pull/offline_sync_pull.dart';

/// Foreground trigger: pull when connectivity returns instead of waiting for
/// the next WorkManager window.
class ConnectivityPullTrigger {
  ConnectivityPullTrigger(
    this.coordinator, {
    Connectivity? connectivity,
  }) : _connectivityStream =
            connectivity?.onConnectivityChanged ?? Connectivity().onConnectivityChanged;

  ConnectivityPullTrigger.forTesting(
    this.coordinator,
    Stream<List<ConnectivityResult>> connectivityStream,
  ) : _connectivityStream = connectivityStream;

  final PullCoordinator coordinator;
  final Stream<List<ConnectivityResult>> _connectivityStream;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Starts listening and calls [PullCoordinator.runAll] when online.
  void start() {
    _subscription ??= _connectivityStream.listen(_onConnectivityChanged);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    if (hasConnection) {
      coordinator.runAll();
    }
  }
}
