# Introduction

**offline_sync** is a monorepo of Dart/Flutter packages for **offline-first** apps that need reliable writes when offline and structured pulls when back online — without folding everything into one generic “sync engine.”

## The problem

Most mobile apps need two different things:

1. **Write path (push)** — User actions while offline must be queued, retried in order, and sometimes chained (upload image → create post with URL).
2. **Read path (pull)** — Lists and details from the server must land in local storage with pagination and resume support.

A flat outbox table handles simple POST retries but cannot express **“run B only after A succeeds, using A’s response.”** A single “sync everything” blob also mixes **your business data** with **sync metadata**.

## What offline_sync provides

| Layer | Packages | Responsibility |
| --- | --- | --- |
| Push | `offline_sync_core`, `offline_sync_flutter` | Job/step queue, handlers, `SyncEngine`, Workmanager |
| Pull | `offline_sync_pull`, `offline_sync_pull_flutter` | Features, steps, checkpoints, `PullCoordinator` |
| UI | `offline_sync_ui` | Job status badges and banners (optional) |

**You still own:**

- Your **AppDatabase** (Drift) — documents, workflows, UI read model
- **Dio** clients and API shapes
- **Handlers** — HTTP + upsert logic inside `SyncTaskHandler` / `PullStepHandler`

The packages orchestrate **when** and **in what order** work runs, and store **sync metadata** in their own SQLite files.

## When to use it

Good fit:

- Dio + Drift (or similar) apps with offline writes and paginated sync
- Multi-step API flows (upload → create, parent job → child job)
- EDMS-style list + detail pulls with checkpoints

Not a fit:

- Real-time-only apps with no local DB
- Apps that only need a simple single-request retry queue with no dependencies (a minimal outbox might suffice)
- Replacing your entire data layer — offline_sync sits **beside** your App DB

## Next steps

- [Core concepts](/guide/core-concepts) — jobs, steps, handlers, checkpoints
- [Architecture](/guide/architecture) — three databases diagram
- [Installation](/guide/installation) — add packages to your app
