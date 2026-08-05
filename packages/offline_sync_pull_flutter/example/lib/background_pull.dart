import 'package:offline_sync_pull_flutter/offline_sync_pull_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'store_and_handlers.dart';

const pullTaskName = 'com.example.offlinesync.pull_flutter.pullTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    return runBackgroundPull(createBackgroundPullCoordinator);
  });
}

@pragma('vm:entry-point')
Future<PullCoordinator> createBackgroundPullCoordinator() async {
  final store = ExampleStore();
  final pullDb = PullDatabase();
  return PullCoordinator(
    db: pullDb,
    registry: buildPullRegistry(store),
  );
}

Future<void> setupBackgroundPull() {
  return initBackgroundPull(
    callbackDispatcher: callbackDispatcher,
    uniqueName: pullTaskName,
    registerPeriodicTask: false,
  );
}
