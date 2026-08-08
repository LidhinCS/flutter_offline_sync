# offline_sync_pull

Dart pull coordinator: paginated lists, entity batches, Drift checkpoints.

## When to use

- Tests without Flutter
- Custom pull orchestration without Workmanager

Apps typically use [offline_sync_pull_flutter](/packages/offline_sync_pull_flutter).

## Install

```yaml
offline_sync_pull:
  git:
    url: https://github.com/LidhinCS/flutter_offline_sync.git
    ref: main
    path: packages/offline_sync_pull
```

## Key exports

- `PullDatabase`, `PullCoordinator`, `PullFeatureRegistry`
- `PullFeature`, `PaginatedListPullStep`, `EntityBatchPullStep`
- `PullStepHandler`, `PullContext`, `PullStepResult`

## Guide

[Pull (read coordinator)](/guide/pull)

## Example

```bash
cd packages/offline_sync_pull/example && flutter run
```

Core-only demo (no Workmanager).
