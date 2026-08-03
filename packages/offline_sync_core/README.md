# offline_sync_core

Offline-first sync engine for Flutter/Dart. Models every offline write as a
**Job** (one user action) made of one or more **Steps** (individual API
calls), where steps can depend on each other's output -- e.g. upload an
image, then create a record using the returned URL.

## Why Job/Step instead of a flat outbox queue

A flat "pending requests" table can't express "run B only after A succeeds,
using A's response." Job/Step is a small DAG per user action:

- **Job**: `feature` + `screen` scoping (so the UI can show "3 pending
  uploads on this screen"), one `idempotencyKey` shared by all its steps.
- **Step**: a `taskType` (maps to a registered handler), `dependsOn` (list
  of sibling stepKeys), `input` (static params), `output` (populated after
  success, consumed by dependents).

A single-step job with no dependencies is just a normal outbox write --
this model is a strict superset of that pattern.

## Quick start

```dart
// 1. Register handlers once at startup (and again in the background
//    isolate entrypoint -- see packages/offline_sync_flutter/example).
final registry = SyncHandlerRegistry()
  ..register('uploadImage', UploadImageHandler(dio))
  ..register('createPost', CreatePostHandler(dio));

final db = SyncDatabase();
final engine = SyncEngine(db: db, registry: registry);

// 2. Enqueue a job with dependent steps.
await JobBuilder(db, feature: 'posts', screen: 'create_post_screen')
    .addStep('uploadImage', taskType: 'uploadImage', input: {'filePath': path})
    .addStep('createPost', taskType: 'createPost',
        input: {'title': title}, dependsOn: ['uploadImage'])
    .enqueue();

// 3. Trigger sync -- on connectivity change and/or from WorkManager.
await engine.syncAll();
```

## Writing a handler

```dart
class UploadImageHandler extends SyncTaskHandler {
  const UploadImageHandler(this.dio);
  final Dio dio;

  @override
  Future<SyncStepResult> execute(SyncContext ctx) async {
    final path = ctx.input['filePath'] as String;
    final resp = await dio.post('/upload',
        data: FormData.fromMap({'file': await MultipartFile.fromFile(path)}));
    return SyncStepResult.success({'imageUrl': resp.data['url']});
  }
}
```

Downstream steps read upstream output via `ctx.dependencyOutput('uploadImage')`.
The engine doesn't know or care what's inside a handler -- multipart
uploads, plain JSON POSTs, GETs, whatever. This is why it composes cleanly
instead of needing a templating DSL for placeholders.

## Partial retry and staleness

On failure, `engine.retryJob(jobId)` does **not** redo the whole job -- it
resets only `failed` steps to `pending` and re-runs. Steps that already
succeeded keep their stored output and are skipped, unless the handler
says otherwise:

```dart
@override
bool isOutputStillValid(Map<String, dynamic> output, DateTime completedAt) {
  // override only when a step's output can go stale before the retry
  // happens, e.g. a presigned URL valid for 15 minutes. Permanent URLs
  // or server-assigned ids should just use the default (always true).
  return DateTime.now().difference(completedAt) < const Duration(minutes: 15);
}
```

## Conflicts are not failures

A `409` (or any business-level conflict) should return
`SyncStepResult.conflict(serverState)`, not `.failure(...)`. This marks the
whole job `JobStatus.conflict`, which the background sync loop skips --
conflicted jobs must not be silently retried on the next connectivity
event. Resolve explicitly:

```dart
await engine.resolveConflict(jobId, 'createPost', resolvedFields);
```

## Background sync in an isolate

Two different concerns, don't conflate them:

- **CPU-bound prep work** (image compression before upload) -- use
  `Isolate.run()` for just that step. Drift's queries and Dio's HTTP calls
  are already async and don't block the UI isolate on their own.
- **True background execution** (app killed/backgrounded) -- needs
  `workmanager`. Its callback runs in a genuinely separate OS-spawned
  isolate with no shared state, so you must re-open the database (same
  file path) and re-register every handler there. See
  `packages/offline_sync_flutter/example`.

`SyncDatabase` opens sqlite in **WAL mode**, which is what makes it safe
for the foreground app and the background isolate to hold independent
connections to the same file concurrently. `SyncEngine.syncAll()`
additionally takes a lightweight cross-isolate lock (a single row,
claimed with a conditional `UPDATE`) so two sync passes never run the
same job at once.

## Interrupted-work recovery

A step or job only stays `running` while a live `runJob()` call is
actively awaiting it. If the app or isolate is killed mid-execute, the
row is left stuck in `running` with nothing left to ever move it forward.
`SyncEngine.syncAll()` calls `recoverInterruptedWork()` at the start of
every pass, which resets anything stuck in `running` back to `pending` so
it gets picked up normally on the next drain. You can also call it
directly once at app startup if you want recovery to happen before the
first real sync trigger fires.

## Coalescing concurrent sync triggers

The cross-isolate DB lock stops two isolates from running the same job at
once, but on its own a `syncAll()` call arriving while another is already
draining would just bail out silently -- and the event that triggered it
(e.g. "connectivity just came back") would be lost. Within a single
`SyncEngine` instance, a `syncAll()` call that arrives mid-drain instead
sets a flag and causes one more full pass to run immediately after the
current one finishes, rather than being dropped or running two passes
concurrently.

iOS background execution via `BGTaskScheduler` (which workmanager wraps)
is best-effort with no guaranteed interval or execution -- don't rely on
it for anything time-sensitive; the connectivity-triggered foreground
sync is what actually gives you low-latency sync when the app is open.

## Codegen

This package uses Drift, so after cloning:

```
dart run build_runner build --delete-conflicting-outputs
```

This generates `lib/src/db/database.g.dart`, which is not checked in.
(This scaffold was built without network access to pub.dev, so codegen
hasn't been run against it yet -- run the command above before first use.)

Each package has a runnable Flutter example under `example/`:

| Package | Example | Demonstrates |
|---|---|---|
| `offline_sync_core` | `packages/offline_sync_core/example` | Job enqueue, `SyncEngine.syncAll()`, Drift streams |
| `offline_sync_flutter` | `packages/offline_sync_flutter/example` | `FlutterSyncCoordinator`, Workmanager setup |
| `offline_sync_ui` | `packages/offline_sync_ui/example` | `SyncStatusBadge`, `SyncScreenBanner`, list tiles |

```bash
cd packages/offline_sync_core/example && flutter run
```

## Design decision: Drift is a direct dependency, not an abstraction

`offline_sync_core` commits directly to Drift/SQLite rather than hiding storage
behind an interface (e.g. a `SyncStore`-style abstraction that Drift would
be one implementation of). That indirection only pays for itself if you
genuinely expect to swap storage engines later; given Drift is already the
standardized choice across these apps, committing directly keeps the
engine simpler to read and change. Revisit this only if a real second
backend requirement shows up -- not preemptively.

## Migrating an existing outbox-pattern sync engine (e.g. EDMS)

| Existing concept | Maps to |
|---|---|
| Outbox row | `SyncJob` with a single `SyncStep`, no `dependsOn` |
| Cross-entity topological ordering | Same algorithm, now scoped per-job via `dependsOn` |
| `If-Match` / 409 handling | Inside the handler; return `.conflict(...)` instead of `.failure(...)` |
| Cursor-based delta pull | Unchanged -- that's the read side, entirely separate from this write queue |
| WorkManager trigger | Unchanged dispatcher, now calls `engine.syncAll()` instead of iterating outbox rows directly |

Existing single-entity writes migrate as one-step jobs; new multi-call
flows (upload-then-create, fetch-id-then-use-it) become multi-step jobs
without touching your conflict resolution or delta-pull logic.
