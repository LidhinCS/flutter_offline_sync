import 'package:flutter/material.dart';
import 'package:offline_sync_pull/offline_sync_pull.dart';

import 'store_and_handlers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = ExampleStore();
  final pullDb = PullDatabase();
  final coordinator = PullCoordinator(
    db: pullDb,
    registry: buildPullRegistry(store),
  );

  runApp(OfflineSyncPullExampleApp(
    store: store,
    pullDb: pullDb,
    coordinator: coordinator,
  ));
}

class OfflineSyncPullExampleApp extends StatelessWidget {
  const OfflineSyncPullExampleApp({
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
      title: 'offline_sync_pull example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)),
      home: PullDemoScreen(
        store: store,
        pullDb: pullDb,
        coordinator: coordinator,
      ),
    );
  }
}

class PullDemoScreen extends StatefulWidget {
  const PullDemoScreen({
    required this.store,
    required this.pullDb,
    required this.coordinator,
    super.key,
  });

  final ExampleStore store;
  final PullDatabase pullDb;
  final PullCoordinator coordinator;

  @override
  State<PullDemoScreen> createState() => _PullDemoScreenState();
}

class _PullDemoScreenState extends State<PullDemoScreen> {
  String? _status;

  Future<void> _runFeature(String name) async {
    setState(() => _status = 'Pulling $name…');
    await widget.coordinator.runFeature(name);
    setState(() => _status = 'Finished $name');
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
      appBar: AppBar(title: const Text('offline_sync_pull')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Core-only demo: tap "Pull next batch" for one bounded coordinator pass. '
            'For Workmanager + connectivity adapters see '
            'offline_sync_pull_flutter/example.',
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(_status!, style: Theme.of(context).textTheme.bodySmall),
          ],
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
