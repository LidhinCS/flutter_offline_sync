# Clean architecture

offline_sync fits **feature-first** clean architecture. Packages stay in **infrastructure**; features own business data and handlers.

## Folder layout

```text
lib/
  core/
    database/          # AppDatabase (all feature tables)
    di/                # SyncModule, PullModule, DatabaseModule
    background/        # Workmanager entrypoints
  features/
    documents/
      data/
        tables/        # Drift Table
        daos/          # @DriftAccessor
        datasources/   # local + remote
        repositories/
        sync/          # optional: pull/push handlers
      domain/
        entities/
        repositories/
      presentation/
        cubit/
        view/
```

## Layer rules

- **Presentation** — Bloc watches App DB via repository streams. No Dio, no `PullCoordinator` in widgets.
- **Domain** — contracts only; no `offline_sync_*` imports.
- **Data** — handlers, DAOs, DTOs, repository impls.
- **core/di** — `SyncModule`, `PullModule`, registries from `buildRegistry` / `buildPullRegistry`.

## Registries

`buildPullRegistry` and `buildRegistry` are filled **when DI first resolves them**. Each new feature needs an explicit `register` call — not automatic when you add a folder.

Inject feature **local datasources** into `PullModule.pullRegistry` so handlers can upsert.

## Reconnect service (app level)

```dart
await getIt<SyncEngine>().syncAll();
await getIt<PullCoordinator>().runAll();
```

Keep this in bootstrap or a dedicated `AppSyncService`, not inside every screen.

## EDMS-style mapping

| Concern | Where |
| --- | --- |
| Document list UI | `features/documents/presentation` |
| Document rows | AppDatabase + DAO |
| List pull handler | `DocumentListPullHandler` → local DS |
| Write enqueue | Repository → `JobBuilder` |
| Checkpoints | `PullDatabase` (package) |

See [Drift & App database](/guide/drift).
