import 'package:drift/drift.dart';

enum PullStepStatus { pending, inProgress, complete }

class PullCheckpoints extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get feature => text()();
  TextColumn get stepKey => text()();

  IntColumn get page => integer().withDefault(const Constant(1))();
  IntColumn get pageSize => integer().withDefault(const Constant(10))();

  TextColumn get status => textEnum<PullStepStatus>()();
  BoolColumn get hasMore => boolean().withDefault(const Constant(true))();

  DateTimeColumn get lastRunAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
}
