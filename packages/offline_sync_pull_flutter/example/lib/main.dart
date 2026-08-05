import 'package:flutter/material.dart';
import 'package:offline_sync_pull_flutter/offline_sync_pull_flutter.dart';

import 'background_pull.dart';
import 'store_and_handlers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = ExampleStore();
  final pullDb = PullDatabase();
  final coordinator = PullCoordinator(
    db: pullDb,
    registry: buildPullRegistry(store),
  );
  final flutterCoordinator = FlutterPullCoordinator(coordinator: coordinator);

  await setupBackgroundPull();
  await flutterCoordinator.startForegroundPull();

  runApp(OfflineSyncPullFlutterExampleApp(
    store: store,
    pullDb: pullDb,
    coordinator: coordinator,
  ));
}

class OfflineSyncPullFlutterExampleApp extends StatelessWidget {
  const OfflineSyncPullFlutterExampleApp({
    required this.store,
    required this.pullDb,
    required this.coordinator,
    super.key,
  });

  final ExampleStore store;
  final PullDatabase pullDb;
  final PullCoordinator coordinator;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'offline_sync_pull_flutter example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: PullFlutterDemoScreen(
        store: store,
        pullDb: pullDb,
        coordinator: coordinator,
      ),
    );
  }
}

class PullFlutterDemoScreen extends StatefulWidget {
  const PullFlutterDemoScreen({
    required this.store,
    required this.pullDb,
    required this.coordinator,
    super.key,
  });

  final ExampleStore store;
  final PullDatabase pullDb;
  final PullCoordinator coordinator;

  @override
  State<PullFlutterDemoScreen> createState() => _PullFlutterDemoScreenState();
}

class _PullFlutterDemoScreenState extends State<PullFlutterDemoScreen> {
  String? _status;

  Future<void> _runFeature(String name) async {
    setState(() => _status = 'Pulling $name…');
    await widget.coordinator.runFeature(name);
    setState(() => _status = 'Finished $name');
  }

  Future<void> _runAll() async {
    setState(() => _status = 'Pulling all features…');
    await widget.coordinator.runAll();
    setState(() => _status = 'Finished all features');
  }

  Future<void> _resetFeature(String name) async {
    if (name == 'documents') {
      await widget.pullDb.resetCheckpoint('documents', 'list');
      widget.store.documents.clear();
    } else {
      await widget.pullDb.resetCheckpoint('workflow', 'list');
      await widget.pullDb.resetCheckpoint('workflow', 'detail');
      widget.store.workflowDetails.clear();
      widget.store.workflowsMissingDetail.clear();
    }
    setState(() => _status = 'Reset $name');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('offline_sync_pull_flutter')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Foreground pull runs via FlutterPullCoordinator (connectivity '
            'trigger). Workmanager is initialized with registerPeriodicTask: '
            'false — use "Pull all" to simulate a manual pass (same as '
            'runBackgroundPull in a task).',
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(_status!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _runAll,
            icon: const Icon(Icons.cloud_download),
            label: const Text('Pull all features'),
          ),
          const SizedBox(height: 24),
          _FeatureSection(
            title: 'Documents (paginated list)',
            onPull: () => _runFeature('documents'),
            onReset: () => _resetFeature('documents'),
            checkpointFuture: widget.pullDb.checkpointFor('documents', 'list'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Local docs (${widget.store.documents.length})'),
                const SizedBox(height: 8),
                if (widget.store.documents.isEmpty)
                  const Text('No documents synced yet.')
                else
                  ...widget.store.documents.map((d) => Text('• $d')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _FeatureSection(
            title: 'Workflow (list + entity-batch detail)',
            onPull: () => _runFeature('workflow'),
            onReset: () => _resetFeature('workflow'),
            checkpointFuture: widget.pullDb.checkpointFor('workflow', 'list'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Workflows pending detail: ${widget.store.workflowsMissingDetail.length}'),
                Text('Workflow details synced: ${widget.store.workflowDetails.length}'),
                const SizedBox(height: 8),
                ...widget.store.workflowDetails.entries.map(
                  (e) => Text('• ${e.key}: ${e.value}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection({
    required this.title,
    required this.onPull,
    required this.onReset,
    required this.checkpointFuture,
    required this.child,
  });

  final String title;
  final VoidCallback onPull;
  final VoidCallback onReset;
  final Future<PullCheckpoint?> checkpointFuture;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            FutureBuilder<PullCheckpoint?>(
              future: checkpointFuture,
              builder: (context, snapshot) {
                final cp = snapshot.data;
                if (cp == null) return const Text('Checkpoint: not started');
                return Text(
                  'Checkpoint: page ${cp.page}, status ${cp.status.name}, '
                  'hasMore ${cp.hasMore}',
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(onPressed: onPull, child: const Text('Pull next batch')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: onReset, child: const Text('Reset demo')),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
