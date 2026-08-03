import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:offline_sync_core/offline_sync_core.dart';

import 'handlers.dart';

const _screen = 'create_post_screen';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = SyncDatabase();
  final engine = SyncEngine(db: db, registry: buildRegistry());

  runApp(OfflineSyncCoreExampleApp(db: db, engine: engine));
}

class OfflineSyncCoreExampleApp extends StatelessWidget {
  const OfflineSyncCoreExampleApp({
    required this.db,
    required this.engine,
    super.key,
  });

  final SyncDatabase db;
  final SyncEngine engine;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'offline_sync_core example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: CreatePostDemoScreen(db: db, engine: engine),
    );
  }
}

class CreatePostDemoScreen extends StatelessWidget {
  const CreatePostDemoScreen({
    required this.db,
    required this.engine,
    super.key,
  });

  final SyncDatabase db;
  final SyncEngine engine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('offline_sync_core'),
        actions: [
          IconButton(
            tooltip: 'Sync now',
            onPressed: engine.syncAll,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: StreamBuilder<List<SyncJob>>(
        stream: db.watchJobsForScreen(_screen),
        builder: (context, snapshot) {
          final jobs = snapshot.data ?? const [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Enqueue a two-step job (upload image → create post), '
                'then tap Sync. Handlers are in-memory fakes — no network.',
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
                label: const Text('Enqueue create-post job'),
              ),
              const SizedBox(height: 24),
              Text('Jobs on this screen (${jobs.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (jobs.isEmpty)
                const Text('No jobs yet.')
              else
                ...jobs.map((job) => _JobCard(job: job, engine: engine)),
            ],
          );
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.engine});

  final SyncJob job;
  final SyncEngine engine;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(_jobLabel(job)),
        subtitle: Text('Status: ${job.status.name}'),
        trailing: job.status == JobStatus.failed
            ? TextButton(
                onPressed: () => engine.retryJob(job.id),
                child: const Text('Retry'),
              )
            : null,
      ),
    );
  }
}

String _jobLabel(SyncJob job) {
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
