/// In-memory stand-in for Dio + a real backend.
///
/// Seeded pages power pull demos; [createNote] / [uploadAttachment] power push.
class FakeNotesApi {
  FakeNotesApi() {
    _seedServerNotes();
  }

  final List<ServerNoteDto> _serverNotes = [];
  int _nextId = 100;

  static const pageSize = 3;

  void _seedServerNotes() {
    const seeds = [
      ('Welcome', 'Pulled from the fake server on first sync.'),
      ('Architecture', 'App DB holds notes; Sync DB holds outbox jobs.'),
      ('Push queue', 'Offline creates enqueue Jobs/Steps until online.'),
      ('Pull pages', 'PullCoordinator walks pages and upserts App DB.'),
      ('Two-step jobs', 'Upload attachment, then create note with its URL.'),
      ('Reconnect', 'Always push (syncAll) before pull (runAll).'),
    ];
    for (var i = 0; i < seeds.length; i++) {
      final (title, body) = seeds[i];
      _serverNotes.add((
        id: 'srv-${i + 1}',
        title: title,
        body: body,
        imageUrl: null,
        idempotencyKey: null,
      ));
    }
  }

  /// Returns one page of notes (1-based [page]).
  Future<({List<ServerNoteDto> notes, bool hasMore})> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final start = (page - 1) * pageSize;
    if (start >= _serverNotes.length) {
      return (notes: const <ServerNoteDto>[], hasMore: false);
    }
    final end = (start + pageSize).clamp(0, _serverNotes.length);
    final slice = _serverNotes.sublist(start, end);
    final hasMore = end < _serverNotes.length;
    return (notes: List<ServerNoteDto>.unmodifiable(slice), hasMore: hasMore);
  }

  Future<String> uploadAttachment(String filePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final name = filePath.split('/').last;
    return 'https://cdn.example.com/notes/$name';
  }

  Future<ServerNoteDto> createNoteDto({
    required String title,
    required String body,
    String? imageUrl,
    required String idempotencyKey,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Idempotent create for retries.
    final existing = _serverNotes.where(
      (n) => n.idempotencyKey == idempotencyKey,
    );
    if (existing.isNotEmpty) return existing.first;

    final note = (
      id: 'srv-${_nextId++}',
      title: title,
      body: body,
      imageUrl: imageUrl,
      idempotencyKey: idempotencyKey,
    );
    _serverNotes.insert(0, note);
    return note;
  }
}

typedef ServerNoteDto = ({
  String id,
  String title,
  String body,
  String? imageUrl,
  String? idempotencyKey,
});
