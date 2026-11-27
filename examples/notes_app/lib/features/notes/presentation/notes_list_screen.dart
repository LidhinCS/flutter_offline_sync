import 'package:flutter/material.dart';
import 'package:flutter_offline_sync_ui/flutter_offline_sync_ui.dart';

import '../../../core/sync/app_services.dart';
import '../data/repositories/notes_repository.dart';
import '../domain/entities/note.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({required this.services, super.key});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    final scope = OfflineSyncScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: SyncActivityIndicator(
                isPushing: services.engine.isSyncingStream,
                isPulling: services.pullCoordinator.isPullingStream,
                db: scope.db,
                feature: NotesRepositoryImpl.feature,
              ),
            ),
          ),
          SyncStatusBadge(db: scope.db, feature: NotesRepositoryImpl.feature),
          IconButton(
            tooltip: 'Sync now (push then pull)',
            onPressed: () async {
              await services.syncNow();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Synced: push then pull')),
                );
              }
            },
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: Column(
        children: [
          SyncScreenBanner(
            screen: NotesRepositoryImpl.screen,
            db: scope.db,
            engine: scope.engine,
          ),
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: services.notesRepository.watchNotes(),
              builder: (context, snapshot) {
                final notes = snapshot.data ?? const [];
                if (notes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No notes yet.\n'
                        'Pull runs on startup; tap Sync or create a note.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      child: ListTile(
                        title: Text(note.title),
                        subtitle: Text(
                          note.body.isEmpty ? '(empty body)' : note.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: _StatusChip(status: note.syncStatus),
                        isThreeLine: note.imageUrl != null,
                        leading: note.imageUrl != null
                            ? const Icon(Icons.image_outlined)
                            : const Icon(Icons.notes),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final NoteSyncStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      NoteSyncStatus.pending => ('pending', Colors.orange),
      NoteSyncStatus.synced => ('synced', Colors.green),
      NoteSyncStatus.failed => ('failed', Colors.red),
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
