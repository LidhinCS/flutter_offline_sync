# offline_sync_pull

Pull coordinator for offline-first Flutter/Dart apps. Complements
[offline_sync_core](../offline_sync_core) on the **read** side: paginated list
sync, entity-batch detail sync, and Drift-backed checkpoints.

`offline_sync_core` = push write queue.  
`offline_sync_pull` = pull ingest orchestration.

## Quick start

```dart
import 'package:offline_sync_pull/offline_sync_pull.dart';

final registry = PullFeatureRegistry()
  ..register(
    PullFeature(
      name: 'documents',
      steps: [
        PaginatedListPullStep(
          key: 'list',
          pageSize: 10,
          handler: DocumentListPullHandler(dio, appDb.documentsDao),
        ),
      ],
    ),
  )
  ..register(
    PullFeature(
      name: 'workflow',
      steps: [
        PaginatedListPullStep(
          key: 'list',
          pageSize: 20,
          handler: WorkflowListPullHandler(dio, appDb),
        ),
        EntityBatchPullStep(
          key: 'detail',
          dependsOn: ['list'],
          batchSize: 10,
          idSelector: (_) => appDb.workflowsDao.idsMissingDetail(),
          handler: WorkflowDetailPullHandler(dio, appDb),
        ),
      ],
    ),
  );

final coordinator = PullCoordinator(
  db: PullDatabase(),
  registry: registry,
);

await coordinator.runFeature('documents');
await coordinator.runAll();
```

## Step types

| Type | Use for |
|---|---|
| `PaginatedListPullStep` | `page=1&limit=10` style list APIs |
| `EntityBatchPullStep` | Per-id detail/stages; `idSelector` returns ids still missing locally |

Handlers call your API and upsert into **your** `AppDatabase` tables. This
package only stores **checkpoints** in `offline_sync_pull.sqlite`.

## With offline_sync (push + pull)

```dart
await engine.syncAll();        // offline_sync_core / flutter
await pullCoordinator.runAll(); // offline_sync_pull
```

For Workmanager + connectivity on the pull side, use
[offline_sync_pull_flutter](../offline_sync_pull_flutter) (`runBackgroundPull`,
`FlutterPullCoordinator`). See `packages/offline_sync_pull_flutter/example`.

## Example

```bash
cd packages/offline_sync_pull/example
flutter run
```

Demonstrates paginated document list sync and workflow list + entity-batch
detail sync with fake handlers. See `example/lib/store_and_handlers.dart`.

## Codegen

```bash
dart run build_runner build --delete-conflicting-outputs
```
