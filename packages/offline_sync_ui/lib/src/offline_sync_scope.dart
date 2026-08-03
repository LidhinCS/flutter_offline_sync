import 'package:flutter/widgets.dart';
import 'package:offline_sync_core/offline_sync_core.dart';

/// Provides [SyncDatabase] and [SyncEngine] to the widget tree.
class OfflineSyncScope extends InheritedWidget {
  const OfflineSyncScope({
    required this.db,
    required this.engine,
    required super.child,
    super.key,
  });

  final SyncDatabase db;
  final SyncEngine engine;

  static OfflineSyncScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<OfflineSyncScope>();
    assert(
      scope != null,
      'OfflineSyncScope not found. Wrap your app (or screen) with OfflineSyncScope.',
    );
    return scope!;
  }

  static OfflineSyncScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OfflineSyncScope>();
  }

  @override
  bool updateShouldNotify(OfflineSyncScope oldWidget) {
    return db != oldWidget.db || engine != oldWidget.engine;
  }
}
