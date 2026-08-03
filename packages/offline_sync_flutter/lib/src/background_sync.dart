import 'package:flutter/widgets.dart';
import 'package:offline_sync_core/offline_sync_core.dart';
import 'package:workmanager/workmanager.dart';

/// Runs a single background sync pass. Call from your Workmanager
/// `executeTask` callback after [WidgetsFlutterBinding.ensureInitialized].
///
/// [createEngine] must be a top-level or static function so it can be invoked
/// from the background isolate — closures cannot cross isolate boundaries.
Future<bool> runBackgroundSync(
  Future<SyncEngine> Function() createEngine,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = await createEngine();
  await engine.syncAll();
  return true;
}

/// Initializes Workmanager and optionally registers a periodic background sync
/// task.
///
/// [callbackDispatcher] must be a top-level function annotated with
/// `@pragma('vm:entry-point')` that calls [runBackgroundSync] with your engine
/// factory. See package README for a full example.
Future<void> initBackgroundSync({
  required void Function() callbackDispatcher,
  required String uniqueName,
  Duration frequency = const Duration(minutes: 15),
  bool registerPeriodicTask = true,
}) async {
  await Workmanager().initialize(callbackDispatcher);
  if (!registerPeriodicTask) return;

  await Workmanager().registerPeriodicTask(
    uniqueName,
    uniqueName,
    frequency: frequency,
    constraints: Constraints(networkType: NetworkType.connected),
  );
}

/// Cancels a previously registered periodic background sync task.
Future<void> cancelBackgroundSync(String uniqueName) {
  return Workmanager().cancelByUniqueName(uniqueName);
}
