import 'package:flutter/material.dart';
import 'package:offline_sync_ui/offline_sync_ui.dart';

import 'handlers.dart';

const _screen = 'create_post_screen';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = SyncDatabase();
  final engine = SyncEngine(db: db, registry: buildRegistry());

  runApp(OfflineSyncUiExampleApp(db: db, engine: engine));
}

class OfflineSyncUiExampleApp extends StatelessWidget {
  const OfflineSyncUiExampleApp({
    required this.db,
    required this.engine,
    super.key,
  });

  final SyncDatabase db;
  final SyncEngine engine;

  @override
  Widget build(BuildContext context) {
    return OfflineSyncScope(
      db: db,
      engine: engine,
      child: MaterialApp(
        title: 'offline_sync_ui example',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        home: const UiDemoScreen(),
      ),
    );
  }
}

class UiDemoScreen extends StatelessWidget {
  const UiDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = OfflineSyncScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('offline_sync_ui'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SyncStatusBadge(db: scope.db, screen: _screen),
          ),
          IconButton(
            tooltip: 'Sync now',
            onPressed: scope.engine.syncAll,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: Column(
        children: [
          SyncScreenBanner(screen: _screen),
          Expanded(
            child: SyncJobsBuilder(
              db: scope.db,
              screen: _screen,
              builder: (context, jobs) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Enqueue jobs to see SyncStatusBadge, SyncScreenBanner, '
                      'and SyncJobListTile update live.',
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        final n = jobs.length + 1;
                        await enqueueCreatePostJob(
                          scope.db,
                          filePath: '/tmp/photo_$n.jpg',
                          title: 'Post $n',
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Enqueue job'),
                    ),
                    const SizedBox(height: 24),
                    Text('All jobs (${jobs.length})',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (jobs.isEmpty)
                      const Text('No jobs yet.')
                    else
                      ...jobs.map(
                        (job) => SyncJobListTile(
                          job: job,
                          engine: scope.engine,
                          onConflictTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Resolve conflict for job #${job.id} in your app',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
