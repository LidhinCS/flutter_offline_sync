import 'package:offline_sync_flutter/offline_sync_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'handlers.dart';

const syncTaskName = 'com.example.offlinesync.flutter.syncTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    return runBackgroundSync(createBackgroundSyncEngine);
  });
}

@pragma('vm:entry-point')
Future<SyncEngine> createBackgroundSyncEngine() async {
  final db = SyncDatabase();
  return createSyncEngine(db);
}

Future<void> setupBackgroundSync() {
  return initBackgroundSync(
    callbackDispatcher: callbackDispatcher,
    uniqueName: syncTaskName,
    registerPeriodicTask: false,
  );
}
