import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_sync_pull_flutter/offline_sync_pull_flutter.dart';

class _OncePullHandler extends PullStepHandler {
  _OncePullHandler(this.onFetch);

  final void Function() onFetch;

  @override
  Future<PullStepResult> fetch(PullContext ctx) async {
    onFetch();
    return const PullStepResult.success(hasMore: false);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  PullCoordinator _coordinator({required void Function() onFetch}) {
    final db = PullDatabase.forTesting(NativeDatabase.memory());
    final registry = PullFeatureRegistry()
      ..register(
        PullFeature(
          name: 'documents',
          steps: [
            PaginatedListPullStep(
              key: 'list',
              pageSize: 10,
              handler: _OncePullHandler(onFetch),
            ),
          ],
        ),
      );
    return PullCoordinator(db: db, registry: registry);
  }

  group('ConnectivityPullTrigger', () {
    test('pulls when connectivity returns', () async {
      final connectivity = StreamController<List<ConnectivityResult>>();
      var pulls = 0;
      final coordinator = _coordinator(onFetch: () => pulls++);

      final trigger = ConnectivityPullTrigger.forTesting(
        coordinator,
        connectivity.stream,
      );
      trigger.start();

      connectivity.add([ConnectivityResult.wifi]);
      await pumpEventQueue();

      expect(pulls, 1);
      await trigger.stop();
      await connectivity.close();
    });
  });

  group('runBackgroundPull', () {
    test('runs coordinator via factory', () async {
      var pulls = 0;
      final result = await runBackgroundPull(() async {
        return _coordinator(onFetch: () => pulls++);
      });

      expect(result, isTrue);
      expect(pulls, 1);
    });
  });

  group('FlutterPullCoordinator', () {
    test('start and stop without error', () async {
      final coordinator = _coordinator(onFetch: () {});
      final flutterCoordinator = FlutterPullCoordinator(coordinator: coordinator);

      await flutterCoordinator.startForegroundPull();
      await flutterCoordinator.stopForegroundPull();
    });
  });
}
