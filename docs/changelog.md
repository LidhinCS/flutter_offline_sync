# Changelog

Aggregated release notes. Per-package changelogs will live in `packages/*/CHANGELOG.md` when publishing starts.

## Unreleased

### Project

- Five packages: core, flutter, pull, pull_flutter, ui
- Melos scripts: analyze, test, build_runner, ci
- Documentation site (VitePress)

### offline_sync_core

- Job/step write queue with `SyncEngine`
- Partial retry, conflict handling, cross-job dependencies

### offline_sync_pull

- `PullCoordinator` with paginated and entity-batch steps
- Drift checkpoint database

### offline_sync_flutter / offline_sync_pull_flutter

- Workmanager background sync
- Connectivity-triggered foreground coordinators

### offline_sync_ui

- Scope, badge, banner, list tile widgets

---

When versions are published, this page will link to pub.dev changelogs.
