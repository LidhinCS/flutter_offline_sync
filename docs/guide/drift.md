# Drift & App database

## Separation

| DB | What goes here |
| --- | --- |
| **AppDatabase** | Your entities — posts, products, users, … |
| **SyncDatabase** | Jobs and steps (package) |
| **PullDatabase** | Checkpoints (package) |

Handlers are the bridge: package calls **your** handler → handler upserts **App DB**.

## AppDatabase setup

- Single `AppDatabase` in `core/database/`
- Feature `tables/` and `daos/` registered on `@DriftDatabase`
- WAL + `busy_timeout` on connection (same pattern as package DBs)

```dart
LazyDatabase openAppConnection() {
  return LazyDatabase(() async {
    final file = File(p.join(dir.path, 'app.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      setup: (raw) {
        raw.execute('PRAGMA journal_mode=WAL;');
        raw.execute('PRAGMA busy_timeout=5000;');
      },
    );
  });
}
```

## DAO pattern

DAOs own SQL. Local datasources wrap DAOs. Repositories wrap datasources. Pull `idSelector` methods call DAO queries like `idsMissingDetail()`.

## UI reads App DB only

```dart
Stream<List<Document>> watchDocuments() => documentsDao.watchAll();
```

Bloc subscribes to repository stream — not to `PullDatabase`.

## Coexistence with package Drift

All three DBs are separate files. Drift may warn if you open the same `AppDatabase` class twice on one executor in tests — use separate executors or close DBs in `tearDown`.

## Codegen

After schema changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

From the repository root: `dart run melos run build_runner`.
