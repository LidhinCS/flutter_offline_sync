# Pull (read coordinator)

The pull path **ingests server data** into your App DB using paginated lists and entity batches, with checkpoints so work can resume.

## Quick start

```dart
import 'package:offline_sync_pull_flutter/offline_sync_pull_flutter.dart';

final registry = PullFeatureRegistry()
  ..register(
    PullFeature(
      name: 'documents',
      steps: [
        PaginatedListPullStep(
          key: 'list',
          pageSize: 20,
          handler: DocumentListPullHandler(dio, documentLocal),
        ),
      ],
    ),
  )
  ..register(
    PullFeature(
      name: 'workflow',
      maxPagesPerRun: 1,
      maxBatchesPerRun: 2,
      steps: [
        PaginatedListPullStep(
          key: 'list',
          pageSize: 20,
          handler: WorkflowListPullHandler(dio, workflowLocal),
        ),
        EntityBatchPullStep(
          key: 'detail',
          dependsOn: ['list'],
          batchSize: 10,
          idSelector: workflowLocal.idsMissingDetail,
          handler: WorkflowDetailPullHandler(dio, workflowLocal),
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
| --- | --- |
| `PaginatedListPullStep` | `page` + `limit` list APIs |
| `EntityBatchPullStep` | Per-id detail; `idSelector` returns ids missing locally |

Handlers call your API and **upsert into AppDatabase** via local datasources — not into `PullDatabase`.

## Checkpoints

`PullDatabase` stores page, `hasMore`, and status per feature/step. Your UI reads **App DB streams**, not checkpoints.

## Bounded runs

`maxPagesPerRun` and `maxBatchesPerRun` cap work per `runFeature()` call — safe for foreground taps and background tasks.

## Flutter adapter

[offline_sync_pull_flutter](/packages/offline_sync_pull_flutter) adds `FlutterPullCoordinator` and `runBackgroundPull`.

## Package reference

[offline_sync_pull](/packages/offline_sync_pull) · [offline_sync_pull_flutter](/packages/offline_sync_pull_flutter)
