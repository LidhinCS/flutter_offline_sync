import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_offline_sync_core/flutter_offline_sync_core.dart';

/// Foreground trigger: sync immediately when connectivity returns, rather than
/// waiting for the next WorkManager window.
class ConnectivitySyncTrigger {
  ConnectivitySyncTrigger(this.engine, {Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      _connectivityStream = null;

  /// Test-only constructor with a custom connectivity stream.
  ConnectivitySyncTrigger.forTesting(
    this.engine,
    Stream<List<ConnectivityResult>> connectivityStream,
  ) : _connectivity = null,
      _connectivityStream = connectivityStream;

  final SyncEngine engine;
  final Connectivity? _connectivity;
  final Stream<List<ConnectivityResult>>? _connectivityStream;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Starts listening for connectivity changes and calls [SyncEngine.syncAll]
  /// when a connection becomes available. Also checks the current status once
  /// so jobs are drained when the app starts already online.
  void start() {
    if (_subscription != null) return;

    final stream = _connectivityStream ?? _connectivity!.onConnectivityChanged;
    _subscription = stream.listen(_onConnectivityChanged);

    // Stream events are only for *changes*. Probe current state so an
    // already-online launch (or a missed toggle) still drains the outbox.
    if (_connectivity != null) {
      unawaited(_syncIfOnline(_connectivity.checkConnectivity()));
    }
  }

  /// Stops listening. Safe to call multiple times.
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (_hasConnection(results)) {
      unawaited(engine.syncAll());
    }
  }

  Future<void> _syncIfOnline(
    Future<List<ConnectivityResult>> resultsFuture,
  ) async {
    final results = await resultsFuture;
    if (_hasConnection(results)) {
      await engine.syncAll();
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
