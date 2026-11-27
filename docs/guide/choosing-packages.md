# Choosing Push or Pull

Pick packages based on the direction of data — not on “sync” as a single blob.

## Decision guide

| Your need | Add |
| --- | --- |
| Queue offline **writes**, retry, multi-step API flows | `flutter_offline_sync_push` |
| Download / refresh **server data** into local DB | `flutter_offline_sync_pull_flutter` |
| Both directions | Both packages above |
| Job status badges / banners / list tiles | `flutter_offline_sync_ui` (optional) |
| Unit tests without Flutter plugins | `flutter_offline_sync_core` and/or `flutter_offline_sync_pull` |

`flutter_offline_sync_push` re-exports `flutter_offline_sync_core`.  
`flutter_offline_sync_pull_flutter` re-exports `flutter_offline_sync_pull`.

## Push only

Use when users create or update data offline and you must flush those writes later.

Examples: create a note, submit a form, upload then create, retry after 5xx.

Start here: [Quick Start](/guide/quick-start) → [Push](/guide/push).

## Pull only

Use when the device should ingest server lists/details into a local DB, with pagination and resume.

Examples: product catalog, document list + detail, workflow list + missing detail batch.

Start here: [Pull](/guide/pull).

## Full stack

Most offline-first apps need **both**:

1. **Push** first on reconnect — flush local writes (`engine.syncAll()`)
2. **Pull** second — refresh from server (`pullCoordinator.runAll()`)

That order avoids overwriting local pending work with a stale server snapshot. See [Architecture](/guide/architecture).

The teaching app [`examples/notes_app`](/examples/) wires both plus UI.

## What about Drift / Dio / Bloc?

- **Drift (or any App DB)** — recommended for business data; packages do **not** require your App DB to be Drift, but package metadata DBs use Drift internally.
- **Dio** — common, not required; handlers can use any HTTP stack.
- **Bloc / Riverpod / GetX / Provider** — optional; packages are architecture-agnostic.

See [Installation](/guide/installation) for `pubspec` snippets.
