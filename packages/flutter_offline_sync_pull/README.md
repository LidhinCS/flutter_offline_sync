# flutter_offline_sync_pull

[![pub package](https://img.shields.io/pub/v/flutter_offline_sync_pull.svg)](https://pub.dev/packages/flutter_offline_sync_pull)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/LidhinCS/flutter_offline_sync/blob/main/packages/flutter_offline_sync_pull/LICENSE)

Pull coordinator for offline-first Flutter/Dart apps. Complements
[flutter_offline_sync_core](https://pub.dev/packages/flutter_offline_sync_core) on the **read** side: paginated list
sync, entity-batch detail sync, and Drift-backed checkpoints.

`flutter_offline_sync_core` = push write queue.  
`flutter_offline_sync_pull` = pull ingest orchestration.

**Docs:** [Pull guide](https://lidhin.github.io/flutter_offline_sync/guide/pull) ·
[GitHub](https://github.com/LidhinCS/flutter_offline_sync)

## Install

```yaml
dependencies:
  flutter_offline_sync_pull: ^0.1.0
```

Most Flutter apps should depend on [`flutter_offline_sync_pull_flutter`](https://pub.dev/packages/flutter_offline_sync_pull_flutter) instead (re-exports this package).

## Quick start

```dart
import 'package:flutter_offline_sync_pull/flutter_offline_sync_pull.dart';

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
package only stores **checkpoints** in `flutter_offline_sync_pull.sqlite`.

## With offline_sync (push + pull)

```dart
await engine.syncAll();        // flutter_offline_sync_core / flutter
await pullCoordinator.runAll(); // flutter_offline_sync_pull
```

For Workmanager + connectivity on the pull side, use
[flutter_offline_sync_pull_flutter](https://pub.dev/packages/flutter_offline_sync_pull_flutter) (`runBackgroundPull`,
`FlutterPullCoordinator`). See `packages/flutter_offline_sync_pull_flutter/example`.

## Activity stream

```dart
coordinator.isPulling;
coordinator.isPullingStream;
```

## Example

```bash
cd packages/flutter_offline_sync_pull/example
flutter run
```

Demonstrates paginated document list sync and workflow list + entity-batch
detail sync with fake handlers. See `example/lib/store_and_handlers.dart`.

## Codegen

```bash
dart run build_runner build --delete-conflicting-outputs
```
