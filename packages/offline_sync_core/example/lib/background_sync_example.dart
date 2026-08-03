// This file shows the `sync_flutter` adapter layer -- the thin Flutter-
// specific glue around the pure-Dart offline_sync_core engine. Add `workmanager`
// and `connectivity_plus` as dependencies of the *app* (or a separate
// sync_flutter package), not of offline_sync_core itself, which stays plain Dart
// and unit-testable without Flutter.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:offline_sync_core/offline_sync_core.dart';
import 'package:workmanager/workmanager.dart';

import '../handlers_example.dart';

const _syncTaskName = 'com.example.app.syncTask';

/// Top-level entrypoint required by workmanager. Runs in a separate OS-
/// spawned isolate with NO shared state with the running app -- database
/// connection, Dio client, and handler registry all have to be recreated
/// here from scratch.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Same sqlite file path as the foreground app -- WAL mode (already
    // configured in SyncDatabase) lets both isolates hold connections
    // safely; the cross-isolate lock in SyncEngine.syncAll prevents them
    // from running the same job at once.
    final db = SyncDatabase(); // uses the default app documents path
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
    // Dio's auth/refresh-token interceptor is registered exactly as it is
    // in the foreground app -- handlers don't special-case background.
    final registry = buildRegistry(dio);
    final engine = SyncEngine(db: db, registry: registry);

    await engine.syncAll();
    return true;
  });
}

/// Call once at app startup (main.dart), alongside registering
/// callbackDispatcher.
Future<void> initBackgroundSync() async {
  await Workmanager().initialize(callbackDispatcher);
  // Periodic minimum on Android is 15 minutes; iOS BGTaskScheduler has no
  // guaranteed interval and is best-effort only -- don't rely on iOS
  // background sync for anything time-sensitive.
  await Workmanager().registerPeriodicTask(
    _syncTaskName,
    _syncTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );
}

/// Foreground trigger: sync immediately when connectivity returns, rather
/// than waiting for the next WorkManager window. This covers the common
/// case (app is open, wifi comes back) with near-zero latency.
class ConnectivitySyncTrigger {
  ConnectivitySyncTrigger(this.engine);
  final SyncEngine engine;

  void start() {
    Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        engine.syncAll();
      }
    });
  }
}
