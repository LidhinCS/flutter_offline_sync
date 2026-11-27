# Pull (read coordinator)

**Pull** downloads server data into **your AppDatabase**, using pagination and optional detail batches, with checkpoints so work can resume.

## What Pull does

1. You register `PullFeature`s with steps and handlers
2. `PullCoordinator.runAll()` / `runFeature()` drives the steps
3. Handlers call **your** API and upsert into **App DB**
4. Progress (page, `hasMore`, errors) is stored in **PullDatabase** — not in App DB

## When to use it

- Refreshing lists from the server
- Fetching detail for ids that are still incomplete locally
- Resuming after the app was killed mid-sync
- Bounding work per foreground tap or background task

## Simple example (paginated list)

```dart
import 'package:flutter_offline_sync_pull_flutter/flutter_offline_sync_pull_flutter.dart';

class NotesListPullHandler extends PullStepHandler {
  NotesListPullHandler(this.api, this.local);

  final NotesApi api; // your type
  final NotesLocalDatasource local; // your type — upserts App DB

  @override
  Future<PullStepResult> fetch(PullContext ctx) async {
    final page = await api.fetchPage(page: ctx.page, pageSize: ctx.pageSize);
    for (final note in page.items) {
      await local.upsertFromServer(note);
    }
    return PullStepResult.success(hasMore: page.hasMore);
  }
}

final pullDb = PullDatabase();
final registry = PullFeatureRegistry()
  ..register(
    PullFeature(
      name: 'notes',
      maxPagesPerRun: 2,
      steps: [
        PaginatedListPullStep(
          key: 'list',
          pageSize: 20,
          handler: NotesListPullHandler(api, local),
        ),
      ],
    ),
  );

final coordinator = PullCoordinator(db: pullDb, registry: registry);
await coordinator.runFeature('notes');
// or: await coordinator.runAll();
```

::: warning
`NotesApi` / `NotesLocalDatasource` are **your** types. The package does not ship them. See [`examples/notes_app`](/examples/) for a complete Fake API + Drift version.
:::

## List + detail (entity batch)

Practical flow:

1. Pull paginated product list → upsert summaries  
2. `idSelector` returns product ids still missing detail  
3. `EntityBatchPullStep` fetches those ids in batches  
4. Upsert details into App DB  
5. Checkpoints track progress; next run continues

```dart
PullFeature(
  name: 'products',
  maxPagesPerRun: 1,
  maxBatchesPerRun: 2,
  steps: [
    PaginatedListPullStep(
      key: 'list',
      pageSize: 20,
      handler: ProductListPullHandler(dio, productLocal),
    ),
    EntityBatchPullStep(
      key: 'detail',
      dependsOn: ['list'],
      batchSize: 10,
      idSelector: productLocal.idsMissingDetail,
      handler: ProductDetailPullHandler(dio, productLocal),
    ),
  ],
)
```

`idSelector` is `Future<List<String>> Function(PullContext ctx)` and should query **your** App DB.

## Step types

| Type | Use for |
| --- | --- |
| `PaginatedListPullStep` | List APIs with page / limit |
| `EntityBatchPullStep` | Detail-by-id; `idSelector` supplies ids |

## Checkpoints & resumability

`PullDatabase` (default file `flutter_offline_sync_pull.sqlite`) stores per feature/step:

- current page  
- `hasMore`  
- status / last error  

If sync is interrupted, the next `runFeature` / `runAll` continues from checkpoints.

**UI rule:** watch App DB streams for lists — not `PullDatabase`.

## Bounded runs

`maxPagesPerRun` and `maxBatchesPerRun` limit work **per coordinator call**. That keeps foreground taps and Workmanager tasks from running unbounded.

## Results

| Result | Meaning |
| --- | --- |
| `PullStepResult.success(hasMore: true/false)` | Page/batch OK; more work or done |
| `PullStepResult.failure(message)` | Error recorded on the checkpoint |

## Flutter adapter

[`flutter_offline_sync_pull_flutter`](/packages/flutter_offline_sync_pull_flutter) adds:

- `FlutterPullCoordinator` — connectivity → `runAll`
- `initBackgroundPull` / `runBackgroundPull`

On reconnect with push + pull, flush writes first: [Architecture — reconnect order](/guide/architecture#reconnect-order).

## Package reference

[flutter_offline_sync_pull](/packages/flutter_offline_sync_pull) · [flutter_offline_sync_pull_flutter](/packages/flutter_offline_sync_pull_flutter)
