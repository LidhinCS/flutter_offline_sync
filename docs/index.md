---
layout: home

hero:
  name: offline_sync
  text: Offline-first sync for Flutter
  tagline: Push write queue, pull coordinator, Workmanager adapters, and optional UI widgets.
  actions:
    - theme: brand
      text: Get started
      link: /guide/introduction
    - theme: alt
      text: View on GitHub
      link: https://github.com/LidhinCS/flutter_offline_sync

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
| [offline_sync_core](/packages/offline_sync_core) | Write queue — `SyncEngine`, jobs/steps, Drift outbox |
| [offline_sync_flutter](/packages/offline_sync_flutter) | Workmanager + connectivity for push |
| [offline_sync_pull](/packages/offline_sync_pull) | Pull coordinator — lists, batches, checkpoints |
| [offline_sync_pull_flutter](/packages/offline_sync_pull_flutter) | Workmanager + connectivity for pull |
| [offline_sync_ui](/packages/offline_sync_ui) | Sync status widgets |

## Choose your path

- **Push only** — add `offline_sync_flutter` for offline writes and background sync.
- **Pull only** — add `offline_sync_pull_flutter` for server-to-device ingest.
- **Full stack** — both adapters + optional `offline_sync_ui` for job status UI.

See [Installation](/guide/installation) for `pubspec` snippets (Git and pub.dev).

<p style="text-align: center; margin-top: 2.5rem;">
  <a href="https://buymeacoffee.com/lidhincs" target="_blank" rel="noreferrer">
    <img
      src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&slug=lidhincs&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff"
      alt="Buy me a coffee"
    />
  </a>
</p>
