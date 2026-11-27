/// Domain note — no offline_sync imports.
enum NoteSyncStatus { pending, synced, failed }

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.syncStatus,
    required this.updatedAt,
    this.serverId,
    this.imageUrl,
  });

  final String id;
  final String? serverId;
  final String title;
  final String body;
  final String? imageUrl;
  final NoteSyncStatus syncStatus;
  final DateTime updatedAt;
}
