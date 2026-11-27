## 0.1.2

### Fixes

- Prefer initializing formals in `SyncEngine` / `JobBuilder` constructors
- Remove unnecessary library name

## 0.1.1

### Fixes

- Shorten pubspec description to meet pub.dev limits
- Correct homepage / documentation URLs (`lidhincs.github.io`)
- Remove obsolete `sqlite3_flutter_libs` dependency (use `sqlite3` 3.x)
- Raise `drift` / `drift_dev` lower bound to `^2.35.3` for generated manager APIs

## 0.1.0

Initial public release.

### Features

- Job/Step write queue with `SyncEngine` and Drift-backed `SyncDatabase`
- `JobBuilder` for enqueueing multi-step DAGs (`dependsOn`, cross-job deps)
- Partial retry: successful steps keep output; only failed steps re-run
- Conflict handling via `SyncStepResult.conflict` + `resolveConflict`
- `syncAll` auto-requeues retryable failed jobs (respects retry budget / backoff)
- `isSyncing` / `isSyncingStream` for foreground busy UI
- Interrupted-work recovery (`recoverInterruptedWork`) for stuck `running` rows
- Cross-isolate DB lock + coalescing concurrent `syncAll` calls
- `pruneCompletedJobs` to bound history of success/cancelled jobs
- Free-form job `meta` for UI labels

### Notes

- Requires Drift codegen artifacts (`lib/src/db/database.g.dart` is included)
