# Clean architecture

flutter_offline_sync fits **feature-first** clean architecture. Packages stay in **infrastructure**; features own business data and handlers.

This layout is **optional**. The packages do not require Bloc, Injectable, or any specific state-management library.

## What this integration accomplishes

- Keeps domain free of sync-package imports  
- Places handlers next to feature data code  
- Centralizes registries and reconnect (`syncAll` then `runAll`)  

## Folder layout

```text
lib/
  core/
    database/          # AppDatabase (all feature tables)
    di/                # composition: registries, engines
    background/        # Workmanager entrypoints
  features/
    <feature>/
      data/
        tables/        # Drift Table (if using Drift)
        daos/
        datasources/   # local + remote
        repositories/
        sync/          # SyncTaskHandler / PullStepHandler
      domain/
        entities/
        repositories/  # contracts only
      presentation/
        # screens / cubit / etc.
```

## Layer rules

- **Presentation** — watches App DB via repository streams. No Dio, no `PullCoordinator` in widgets.
- **Domain** — contracts only; no `flutter_offline_sync_*` imports.
- **Data** — handlers, DAOs, DTOs, repository impls; repositories call `JobBuilder`.
- **core** — build `SyncEngine` / `PullCoordinator`, `buildRegistry` / `buildPullRegistry`.

## Registries

Fill `buildRegistry` / `buildPullRegistry` when you compose the app (or when DI first resolves them). Each feature needs an explicit `register` — adding a folder does nothing by itself.

Inject feature **local datasources** into pull handlers so they can upsert App DB.

## Reconnect (app level)

```dart
await engine.syncAll();
await pullCoordinator.runAll();
```

Keep this in bootstrap or a dedicated app sync service — not inside every screen. If you use GetIt:

```dart
await getIt<SyncEngine>().syncAll();
await getIt<PullCoordinator>().runAll();
```

GetIt is optional; background isolates must **not** rely on it — [Foreground & background](/guide/foreground-background).

## Example mapping

| Concern | Where |
| --- | --- |
| Feature list UI | `features/<name>/presentation` |
| Feature rows | AppDatabase + DAO |
| List pull handler | Feature `PullStepHandler` → local datasource |
| Write enqueue | Repository → `JobBuilder` |
| Checkpoints | `PullDatabase` (package) |

Working sample: [`examples/notes_app`](/examples/).

See [Drift & App database](/guide/drift).
