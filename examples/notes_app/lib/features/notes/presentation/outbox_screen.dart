import 'package:flutter/material.dart';
import 'package:flutter_offline_sync_ui/flutter_offline_sync_ui.dart';

import '../../../core/sync/app_services.dart';
import '../data/repositories/notes_repository.dart';

/// Watches SyncDatabase jobs — not AppDatabase notes.
class OutboxScreen extends StatelessWidget {
  const OutboxScreen({required this.services, super.key});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    final scope = OfflineSyncScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outbox'),
        actions: [
          IconButton(
            tooltip: 'Sync now',
            onPressed: services.syncNow,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: SyncJobsBuilder(
        db: scope.db,
        feature: NotesRepositoryImpl.feature,
        builder: (context, jobs) {
          if (jobs.isEmpty) {
            return const Center(
              child: Text('No outbox jobs. Create a note to enqueue one.'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'These rows live in SyncDatabase (sync_core.sqlite). '
                'Your notes list reads AppDatabase (app.sqlite).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ...jobs.map(
                (job) => SyncJobListTile(
                  job: job,
                  engine: scope.engine,
                  onConflictTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Conflict on job #${job.id} — wire resolveConflict '
                          'in a real app.',
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
    );
  }
}
