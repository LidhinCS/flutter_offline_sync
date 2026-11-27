# FAQ

Answers match the current package behavior. Configuration-dependent cases are called out.

## What happens when the device is offline?

`JobBuilder.enqueue()` still persists jobs in SyncDatabase. `syncAll()` / pull runs fail or no-op on network errors depending on your handler — pending push jobs remain until a later successful sync. Connectivity helpers in `FlutterSyncCoordinator` / `FlutterPullCoordinator` retry when online.

## How do I trigger synchronization?

| Trigger | API |
| --- | --- |
| Manual | `engine.syncAll()`, `pullCoordinator.runAll()` / `runFeature` |
| Foreground connectivity | `FlutterSyncCoordinator.startForegroundSync()`, `FlutterPullCoordinator.startForegroundPull()` |
| Background | Workmanager + `runBackgroundSync` / `runBackgroundPull` |

## What happens when a job fails?

The step is marked failed. If `SyncStepResult.failure(..., retryable: true)` (default), a later `syncAll` can requeue it. Use `retryable: false` for permanent client errors. Call `engine.retryJob(jobId)` for partial retry of failed steps.

## Can jobs depend on each other?

**Within a job:** yes — `dependsOn: ['otherStepKey']`.  
**Across jobs:** yes — `externalDependsOn` with `CrossJobDependency` / `FieldMapping` (see core package README).

## How does retry work?

- Automatic: retryable failures can be picked up on subsequent `syncAll` passes  
- Manual: `retryJob` resets failed steps and re-runs; successful steps with valid output are skipped  
- Override `isOutputStillValid` when success output expires  

The packages do **not** claim exactly-once delivery to your server — use idempotency keys / server-side idempotency.

## How do I resume a pull?

Checkpoints in `PullDatabase` store page/`hasMore`/status. Call `runFeature` / `runAll` again; the coordinator continues from checkpoints. Your handlers must upsert App DB on each successful fetch.

## Does the package require Drift for my app data?

No. **Your** App DB can be Drift, Isar, sqflite, etc. Package metadata DBs (`SyncDatabase`, `PullDatabase`) use Drift internally.

## Does it require Firebase?

No.

## Can I use Dio?

Yes. Handlers commonly take a `Dio` instance. Any HTTP client works.

## Can I use another state management solution?

Yes. Packages are UI-agnostic. Bloc/Riverpod/GetX/Provider are optional.

## Can I run synchronization in the background?

Yes, via Workmanager adapters in `flutter_offline_sync_push` and `flutter_offline_sync_pull_flutter`. Respect platform limits (Android ~15 min periodic minimum; iOS best-effort).

## How is synchronization progress tracked?

| Path | Progress store |
| --- | --- |
| Push | Job/step rows in SyncDatabase |
| Pull | Checkpoints in PullDatabase |

## What happens if the app is terminated mid-sync?

Steps left `running` are recovered by `recoverInterruptedWork()` (also invoked from `FlutterSyncCoordinator.startForegroundSync` and at the start of `syncAll`). Pull resumes from checkpoints on the next run.

## How do I debug a failed handler?

1. Confirm the `taskType` is registered in **this** isolate’s registry  
2. Inspect SyncDatabase job/step status and error fields  
3. Log inside `execute` / `fetch`  
4. Distinguish retryable failure vs conflict vs missing dependency output  

## Still stuck?

See [Troubleshooting](/guide/troubleshooting) or open a GitHub issue with platform, foreground vs background, package versions, and push vs pull.
