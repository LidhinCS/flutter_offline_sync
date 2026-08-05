import 'package:flutter/widgets.dart';
import 'package:offline_sync_pull/offline_sync_pull.dart';
import 'package:workmanager/workmanager.dart';

/// Runs a single background pull pass. Call from your Workmanager
/// `executeTask` callback after [WidgetsFlutterBinding.ensureInitialized].
///
/// [createCoordinator] must be a top-level or static function so it can be
/// invoked from the background isolate.
Future<bool> runBackgroundPull(
  Future<PullCoordinator> Function() createCoordinator,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  final coordinator = await createCoordinator();
  await coordinator.runAll();
  return true;
}

/// Initializes Workmanager and optionally registers a periodic background pull
/// task (e.g. every 15 minutes).
Future<void> initBackgroundPull({
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

/// Cancels a previously registered periodic background pull task.
Future<void> cancelBackgroundPull(String uniqueName) {
  return Workmanager().cancelByUniqueName(uniqueName);
}
