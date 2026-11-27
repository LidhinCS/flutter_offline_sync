import 'package:drift/drift.dart';

/// Business rows live in AppDatabase — never in SyncDatabase / PullDatabase.
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get body => text().withDefault(const Constant(''))();
  TextColumn get imageUrl => text().nullable()();

  /// pending | synced | failed
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
