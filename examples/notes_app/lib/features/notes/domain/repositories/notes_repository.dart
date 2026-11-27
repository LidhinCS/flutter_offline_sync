import '../entities/note.dart';

/// Domain contract — presentation and domain never import offline_sync_*.
abstract class NotesRepository {
  Stream<List<Note>> watchNotes();

  Future<void> createNote({
    required String title,
    required String body,
    String? attachmentPath,
  });
}
