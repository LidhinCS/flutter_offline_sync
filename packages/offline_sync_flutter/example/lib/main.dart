import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:offline_sync_flutter/offline_sync_flutter.dart';

import 'background_sync.dart';
import 'handlers.dart';

const _screen = 'create_post_screen';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = SyncDatabase();
  final engine = await createSyncEngine(db);
  final coordinator = FlutterSyncCoordinator(engine: engine);

  await setupBackgroundSync();
  await coordinator.startForegroundSync();

  runApp(OfflineSyncFlutterExampleApp(db: db, engine: engine));
}

class OfflineSyncFlutterExampleApp extends StatelessWidget {
  const OfflineSyncFlutterExampleApp({
    required this.db,
    required this.engine,
    super.key,
  });

  final SyncDatabase db;
  final SyncEngine engine;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'offline_sync_flutter example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: FlutterAdapterDemoScreen(db: db, engine: engine),
    );
  }
}

class FlutterAdapterDemoScreen extends StatelessWidget {
  const FlutterAdapterDemoScreen({
    required this.db,
    required this.engine,
    super.key,
  });

  final SyncDatabase db;
  final SyncEngine engine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('offline_sync_flutter')),
      body: StreamBuilder<List<SyncJob>>(
        stream: db.watchJobsForScreen(_screen),
        builder: (context, snapshot) {
          final jobs = snapshot.data ?? const [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Foreground sync runs via FlutterSyncCoordinator (connectivity '
                'trigger + startup recovery). Background Workmanager is initialized '
                'with registerPeriodicTask: false in this demo.',
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final n = jobs.length + 1;
                  await enqueueCreatePostJob(
                    db,
                    filePath: '/tmp/photo_$n.jpg',
                    title: 'Post $n',
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Enqueue job'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: engine.syncAll,
                icon: const Icon(Icons.sync),
                label: const Text('Sync now'),
              ),
              const SizedBox(height: 24),
              Text('Jobs (${jobs.length})', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (jobs.isEmpty)
                const Text('No jobs yet.')
              else
                ...jobs.map(
                  (job) => ListTile(
                    title: Text(jobDisplayLabel(job)),
                    subtitle: Text(job.status.name),
                    trailing: job.status == JobStatus.failed
                        ? TextButton(
                            onPressed: () => engine.retryJob(job.id),
                            child: const Text('Retry'),
                          )
                        : null,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

String jobDisplayLabel(SyncJob job) {
  final raw = job.meta;
  if (raw != null) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final label = map['label'];
      if (label is String && label.isNotEmpty) return label;
    } on FormatException {
      // Fall through.
    }
  }
  return 'Job #${job.id}';
}
