# Core concepts

## Push (write path)

| Concept | Meaning |
| --- | --- |
| **Job** | One user action (e.g. “create post”). Scoped by `feature` + `screen` for UI. |
| **Step** | One API operation inside a job. Has `taskType`, `input`, optional `dependsOn`. |
| **Handler** | `SyncTaskHandler` — your code: HTTP + return `SyncStepResult`. |
| **Registry** | `SyncHandlerRegistry` — maps `taskType` → handler. |
| **Engine** | `SyncEngine` — drains pending jobs, respects dependencies, retries. |
| **SyncDatabase** | Package DB — jobs and steps only (`sync_core.sqlite`). |

A single-step job with no dependencies is equivalent to a classic outbox row.

## Pull (read path)

| Concept | Meaning |
| --- | --- |
| **Feature** | Named sync unit (e.g. `posts`, `products`). |
| **Step** | `PaginatedListPullStep` or `EntityBatchPullStep`. |
| **Handler** | `PullStepHandler` — fetch page or batch, upsert into **App DB**. |
| **Checkpoint** | Row in `PullDatabase` — current page, `hasMore`, status. |
| **Coordinator** | `PullCoordinator` — runs steps with per-run caps. |
| **Registry** | `PullFeatureRegistry` — maps feature name → `PullFeature`. |

`idSelector` on entity-batch steps reads **your** local DB (“which ids still need detail?”).

## Foreground vs background

| Context | Isolate | DI / GetIt | Dio |
| --- | --- | --- | --- |
| Foreground app | Main | Yes | `@Named('mainNetworkClient')` |
| Workmanager task | Background | **No** — rebuild factories | New `Dio` from shared factory |

Handler **registries** are rebuilt in background; they are in-memory maps, not persisted.

## Results handlers return

**Push**

- `SyncStepResult.success(output)` — step done; output available to dependents
- `SyncStepResult.failure(message)` — retryable failure
- `SyncStepResult.conflict(serverState)` — job paused for user resolution

**Pull**

- `PullStepResult.success(hasMore: true/false)` — paginated progress
- `PullStepResult.failure(message)` — checkpoint records error
