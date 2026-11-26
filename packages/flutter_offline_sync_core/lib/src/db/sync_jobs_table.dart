import 'package:drift/drift.dart';

/// One logical user-initiated write, e.g. "create post", "submit inspection".
/// A job groups one or more sync steps that may depend on each other.
class SyncJobs extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Used to scope queries like "pending jobs for this screen/feature",
  /// so the UI can show e.g. "3 uploads pending" or cancel drafts.
  TextColumn get feature => text()();
  TextColumn get screen => text()();

  /// pending | running | success | failed | conflict | cancelled
  TextColumn get status => textEnum<JobStatus>()();

  /// Sent as a header (e.g. Idempotency-Key) on every step's request so
  /// retries after partial failure don't create duplicate server-side
  /// records or files.
  TextColumn get idempotencyKey => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// Free-form json for whatever the UI wants to show (e.g. a label,
  /// a thumbnail path) without joining into step data.
  TextColumn get meta => text().nullable()();
}

enum JobStatus { pending, running, success, failed, conflict, cancelled }
