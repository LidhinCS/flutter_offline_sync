import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/notes/data/daos/notes_dao.dart';
import '../../features/notes/data/tables/notes_table.dart';

part 'app_database.g.dart';

LazyDatabase openAppConnection({String? dbPath}) {
  return LazyDatabase(() async {
    final path = dbPath ?? await _defaultDbPath();
    final file = File(path);
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        rawDb.execute('PRAGMA journal_mode=WAL;');
        rawDb.execute('PRAGMA busy_timeout=5000;');
      },
    );
  });
}

Future<String> _defaultDbPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, 'app.sqlite');
}

/// Your app's business database — separate from SyncDatabase and PullDatabase.
@DriftDatabase(tables: [Notes], daos: [NotesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase({String? dbPath}) : super(openAppConnection(dbPath: dbPath));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
