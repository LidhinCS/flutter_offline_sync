---
layout: home

hero:
  name: flutter_offline_sync
  text: Offline-first sync for Flutter
  tagline: Queue offline writes, retry with dependencies, and pull server data into your local database — without replacing your app architecture.
  image:
    src: /hero.png
    alt: Flutter offline sync — phone, local database, and offline indicator
  actions:
    - theme: brand
      text: Quick Start
      link: /guide/quick-start
    - theme: alt
      text: Introduction
      link: /guide/introduction

features:
  - title: Push queue
    details: Model offline writes as Jobs and Steps — upload then create, cross-step dependencies, partial retry, and conflict handling.
  - title: Pull coordinator
    details: Paginated list sync and entity-batch detail pulls with Drift-backed checkpoints. Your handlers upsert into AppDatabase.
  - title: Flutter adapters
    details: Workmanager background sync and connectivity-triggered foreground sync for push and pull.
  - title: Optional UI
    details: Badges, banners, and list tiles wired to sync job streams per screen.
---

## Packages

| Package | Role |
| --- | --- |
| [flutter_offline_sync_core](/packages/flutter_offline_sync_core) | Write queue — `SyncEngine`, jobs/steps, Drift outbox |
| [flutter_offline_sync_push](/packages/flutter_offline_sync_push) | Workmanager + connectivity for push |
| [flutter_offline_sync_pull](/packages/flutter_offline_sync_pull) | Pull coordinator — lists, batches, checkpoints |
| [flutter_offline_sync_pull_flutter](/packages/flutter_offline_sync_pull_flutter) | Workmanager + connectivity for pull |
| [flutter_offline_sync_ui](/packages/flutter_offline_sync_ui) | Sync status widgets |

## Choose your path

- **New here?** — [Introduction](/guide/introduction) → [Installation](/guide/installation) → [Quick Start](/guide/quick-start)
- **Push only** — add `flutter_offline_sync_push` for offline writes and background sync
- **Pull only** — add `flutter_offline_sync_pull_flutter` for server-to-device ingest
- **Full stack** — both adapters + optional `flutter_offline_sync_ui`

Prefer the runnable **[Offline Notes example](/examples/)** (`examples/notes_app`) to see App DB + push + pull + UI together.

See [Choosing Push or Pull](/guide/choosing-packages) for a decision table.
