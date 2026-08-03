import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:offline_sync_core/offline_sync_core.dart';

/// Foreground trigger: sync immediately when connectivity returns, rather than
/// waiting for the next WorkManager window.
class ConnectivitySyncTrigger {
  ConnectivitySyncTrigger(
    this.engine, {
    Connectivity? connectivity,
  }) : _connectivityStream =
            connectivity?.onConnectivityChanged ?? Connectivity().onConnectivityChanged;

  /// Test-only constructor with a custom connectivity stream.
  ConnectivitySyncTrigger.forTesting(
    this.engine,
    Stream<List<ConnectivityResult>> connectivityStream,
  ) : _connectivityStream = connectivityStream;

  final SyncEngine engine;
  final Stream<List<ConnectivityResult>> _connectivityStream;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Starts listening for connectivity changes and calls [SyncEngine.syncAll]
  /// when a connection becomes available.
  void start() {
    _subscription ??= _connectivityStream.listen(_onConnectivityChanged);
  }

  /// Stops listening. Safe to call multiple times.
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    if (hasConnection) {
      engine.syncAll();
    }
  }
}
