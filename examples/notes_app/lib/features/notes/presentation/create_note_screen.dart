import 'package:flutter/material.dart';
import 'package:flutter_offline_sync_ui/flutter_offline_sync_ui.dart';

import '../../../core/sync/app_services.dart';
import '../data/repositories/notes_repository.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({required this.services, super.key});

  final AppServices services;

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _withAttachment = false;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.services.notesRepository.createNote(
        title: title,
        body: _bodyController.text.trim(),
        attachmentPath: _withAttachment
            ? '/tmp/note_${DateTime.now().millisecondsSinceEpoch}.jpg'
            : null,
      );
      if (!mounted) return;
      _titleController.clear();
      _bodyController.clear();
      setState(() => _withAttachment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Saved locally + enqueued outbox job. Tap Sync to push.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = OfflineSyncScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create note'),
        actions: [
          SyncStatusBadge(db: scope.db, screen: NotesRepositoryImpl.screen),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SyncScreenBanner(
            screen: NotesRepositoryImpl.screen,
            db: scope.db,
            engine: scope.engine,
          ),
          const SizedBox(height: 8),
          Text(
            'Creates an optimistic App DB row, then enqueues a SyncDatabase '
            'job. With attachment: uploadAttachment → createNote (dependsOn).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(
              labelText: 'Body',
              border: OutlineInputBorder(),
            ),
            minLines: 3,
            maxLines: 6,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Include fake attachment'),
            subtitle: const Text('Two-step job: upload then create'),
            value: _withAttachment,
            onChanged: _saving
                ? null
                : (v) => setState(() => _withAttachment = v),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Saving…' : 'Save offline'),
          ),
        ],
      ),
    );
  }
}
