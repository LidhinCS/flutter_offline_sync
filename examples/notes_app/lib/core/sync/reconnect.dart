import 'package:flutter_offline_sync_pull_flutter/flutter_offline_sync_pull_flutter.dart';
import 'package:flutter_offline_sync_push/flutter_offline_sync_push.dart';

/// App-level reconnect order: flush writes, then ingest reads.
Future<void> reconnectSync({
  required SyncEngine engine,
  required PullCoordinator pullCoordinator,
}) async {
  await engine.syncAll();
  await pullCoordinator.runAll();
}
