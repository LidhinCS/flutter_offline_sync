# Quick Start

Goal: enqueue one offline write, then flush it with `SyncEngine.syncAll()`.

This page uses **push only** (`flutter_offline_sync_push`). No Workmanager, DI framework, or multi-step DAG yet.

::: tip
For a full app with App DB + push + pull + UI, run [`examples/notes_app`](/examples/).
:::

## Prerequisites

- Flutter app (SDK versions: see each package `pubspec.yaml`)
- Ability to call your API from Dart (Dio, `http`, etc. — your choice)

## 1. Install

```yaml
dependencies:
  flutter_offline_sync_push: ^0.1.0
```

Then:

```bash
flutter pub get
```

`flutter_offline_sync_push` re-exports `flutter_offline_sync_core`, so you import one package.

## 2. Write a handler

A **handler** is your code for one API operation. The engine never calls HTTP itself.

```dart
import 'package:flutter_offline_sync_push/flutter_offline_sync_push.dart';

/// Replace the body with your real HTTP call (Dio, http, …).
class CreateTaskHandler extends SyncTaskHandler {
  const CreateTaskHandler();

  @override
  Future<SyncStepResult> execute(SyncContext ctx) async {
    final title = ctx.input['title'] as String;

    // Example placeholder — swap for your API:
    // final response = await dio.post('/tasks', data: {'title': title});
    // final serverId = response.data['id'] as String;
    final serverId = 'task-${title.hashCode}';

    // Optionally upsert into your AppDatabase here.

    return SyncStepResult.success({
      'serverId': serverId,
      'title': title,
    });
  }
}
```

Return values (real API):

- `SyncStepResult.success(Map output)` — step done; map is available to dependent steps
- `SyncStepResult.failure(String error, {bool retryable = true})` — failed; retryable failures can auto-retry on later `syncAll`
- `SyncStepResult.conflict(Map serverState)` — pause for user resolution (see [Push](/guide/push))

## 3. Register, open DB, create engine

```dart
import 'package:flutter_offline_sync_push/flutter_offline_sync_push.dart';

SyncHandlerRegistry buildRegistry() {
  return SyncHandlerRegistry()
    ..register('createTask', const CreateTaskHandler());
}

Future<void> bootstrapSync() async {
  final syncDb = SyncDatabase(); // default file: sync_core.sqlite
  final engine = SyncEngine(
    db: syncDb,
    registry: buildRegistry(),
  );

  // Keep syncDb + engine somewhere your UI/repository can reach
  // (InheritedWidget, Riverpod, GetIt, … — your choice).
}
```

## 4. Enqueue a job

A **job** is one user action. Here it has a single **step**.

```dart
Future<void> saveTaskOffline(SyncDatabase syncDb, String title) async {
  await JobBuilder(
    syncDb,
    feature: 'tasks',
    screen: 'create_task_screen',
    meta: {'label': 'Create "$title"'},
  )
      .addStep(
        'createTask',
        taskType: 'createTask', // must match registry key
        input: {'title': title},
      )
      .enqueue();
}
```

What this does:

1. Persists a pending job + step in **SyncDatabase** (survives app restarts)
2. Does **not** call the network yet
3. UI can keep working offline

::: tip Optimistic UI
If you want the list to update immediately, insert into **your AppDatabase** in the repository, then enqueue. See [Offline Notes](/examples/).
:::

## 5. Trigger synchronization

When you want to flush the queue (button, connectivity, startup):

```dart
await engine.syncAll();
```

`syncAll()`:

- Finds pending / retryable-failed jobs
- Runs each step’s handler in dependency order
- Stores success output or failure/conflict status in SyncDatabase

While offline, leave jobs pending and call `syncAll()` again when online. Or use `FlutterSyncCoordinator` for connectivity-triggered sync — [Foreground & background](/guide/foreground-background).

## Expected lifecycle

```text
User taps Save
  → JobBuilder.enqueue()     // SyncDatabase: pending
  → (device offline)         // nothing runs yet
  → connectivity / Sync now
  → engine.syncAll()
  → CreateTaskHandler.execute
  → SyncStepResult.success   // SyncDatabase: success
```

Inspect jobs with `syncDb.watchJobsForScreen('create_task_screen')` or the [UI widgets](/guide/ui).

## What you should replace

| Placeholder | Replace with |
| --- | --- |
| `CreateTaskHandler` body | Your authenticated HTTP call |
| `feature` / `screen` strings | Keys you use for UI scoping |
| Keeping `engine` / `syncDb` | Your DI or app services |

## Next steps

- [Choosing Push or Pull](/guide/choosing-packages) — do you also need pull?
- [Push guide](/guide/push) — multi-step jobs, conflicts, partial retry  
- [Pull guide](/guide/pull) — server → App DB  
- [Core concepts](/guide/core-concepts) — vocabulary reference  
