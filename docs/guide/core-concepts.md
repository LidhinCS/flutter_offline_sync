# Core concepts

Short reference for the vocabulary used across the guides. For a working walkthrough, see [Quick Start](/guide/quick-start).

---

## Job

**In simple terms:** A queued user action your app wants to finish (for example “create task”).

**Why it exists:** Groups one or more API calls under one outbox unit with shared `feature`, `screen`, and `idempotencyKey`.

**How it works:** Created via `JobBuilder` into `SyncDatabase`. Scoped by `feature` + `screen` so UI can show pending work per screen.

**Example:**

```dart
await JobBuilder(
  syncDb,
  feature: 'tasks',
  screen: 'create_task_screen',
  meta: {'label': 'Create "Buy milk"'},
)
    .addStep('createTask', taskType: 'createTask', input: {'title': 'Buy milk'})
    .enqueue();
```

---

## Step

**In simple terms:** One API operation inside a job.

**Why it exists:** Lets you chain work (upload → create) and retry only the parts that failed.

**How it works:** Each step has a `stepKey`, `taskType` (handler lookup), `input` map, and optional `dependsOn` list of other step keys in the same job.

**Example:**

```dart
.addStep('uploadImage', taskType: 'uploadImage', input: {'filePath': path})
.addStep(
  'createPost',
  taskType: 'createPost',
  input: {'title': title},
  dependsOn: ['uploadImage'],
)
```

A job with one step and no dependencies behaves like a classic outbox row.

---

## Handler (`SyncTaskHandler`)

**In simple terms:** Your code that performs the network (or other) work for a `taskType`.

**Why it exists:** The engine must stay transport-agnostic; you own HTTP, auth, and App DB upserts.

**How it works:** Implement `execute(SyncContext ctx)` and return a `SyncStepResult`. Register the handler by `taskType`.

**Example:**

```dart
class CreateTaskHandler extends SyncTaskHandler {
  const CreateTaskHandler();

  @override
  Future<SyncStepResult> execute(SyncContext ctx) async {
    final title = ctx.input['title'] as String;
    // await dio.post(...);
    return SyncStepResult.success({'serverId': '…', 'title': title});
  }
}
```

---

## Registry (`SyncHandlerRegistry`)

**In simple terms:** A map from `taskType` string → handler instance.

**Why it exists:** Jobs store `taskType` as data; the engine resolves handlers at runtime.

**How it works:** Call `register` at startup **and** again in background isolate factories (maps are in-memory, not persisted).

```dart
SyncHandlerRegistry()
  ..register('createTask', const CreateTaskHandler());
```

---

## Engine (`SyncEngine`)

**In simple terms:** Drains the outbox: runs pending jobs, respects step dependencies, stores results, supports retry and conflict resolution.

**Why it exists:** Central place for execution policy without putting that logic in every screen.

**How it works:**

```dart
final engine = SyncEngine(db: syncDb, registry: registry);
await engine.syncAll();
await engine.retryJob(jobId);
await engine.resolveConflict(jobId, 'createPost', resolvedFields);
```

Also: `recoverInterruptedWork()`, `cancelJobsForScreen(screen)`, `isSyncing` / `isSyncingStream`.

---

## SyncDatabase

**In simple terms:** The package SQLite file for **jobs and steps only** (default `sync_core.sqlite`).

**Why it exists:** Keeps sync metadata out of your business AppDatabase.

**How it works:** Opened by `SyncDatabase()`. Foreground and background must use the same file path. Not for product entities.

---

## Feature (pull)

**In simple terms:** A named pull unit (for example `products` or `notes`).

**Why it exists:** Lets you run or bound sync per domain (`runFeature('products')` vs `runAll()`).

```dart
PullFeature(
  name: 'notes',
  maxPagesPerRun: 2,
  steps: [/* … */],
)
```

---

## Pull step

**In simple terms:** One pull operation inside a feature.

**Why it exists:** Separates “list pages” from “fetch missing details.”

| Type | Use |
| --- | --- |
| `PaginatedListPullStep` | Walk `page` until `hasMore` is false |
| `EntityBatchPullStep` | Fetch a batch of ids from `idSelector` |

---

## Pull handler (`PullStepHandler`)

**In simple terms:** Your code that fetches a page/batch and upserts into **App DB**.

**How it works:** Implement `fetch(PullContext ctx)` → `PullStepResult.success(hasMore: …)` or `.failure(message)`.

---

## Checkpoint

**In simple terms:** Saved pull progress (page, `hasMore`, status) in `PullDatabase`.

**Why it exists:** Resume after interruption without re-downloading everything from page 1 blindly.

**Important:** Your UI should watch **App DB** streams, not checkpoints.

---

## Coordinator (`PullCoordinator`)

**In simple terms:** Runs registered pull features with per-run caps (`maxPagesPerRun`, `maxBatchesPerRun`).

```dart
final coordinator = PullCoordinator(db: pullDb, registry: pullRegistry);
await coordinator.runAll();
await coordinator.runFeature('notes');
```

Also: `isPulling` / `isPullingStream`.

---

## Push results vs pull results

**Push — `SyncStepResult`**

- `.success(output)`
- `.failure(error, {retryable})`
- `.conflict(serverState)`

**Pull — `PullStepResult`**

- `.success({hasMore})`
- `.failure(message)`

---

## Foreground vs background (isolate)

| Context | Rebuild Dio + registries? | Use GetIt / app singletons? |
| --- | --- | --- |
| Main isolate | Once at app start | Yes, if you want |
| Workmanager isolate | **Always** in top-level factories | **No** |

See [Foreground & background](/guide/foreground-background).
