## 0.1.1

### Fixes

- Shorten pubspec description to meet pub.dev limits
- Correct homepage / documentation URLs (`lidhincs.github.io`)
- Raise `drift` / `drift_dev` lower bound to `^2.35.3` for generated manager APIs

## 0.1.0

Initial public release.

### Features

- `PullCoordinator` with feature registry
- `PaginatedListPullStep` for page/limit list APIs
- `EntityBatchPullStep` for per-id detail / stage fetches
- Drift-backed `PullDatabase` checkpoints (separate from app tables)
- `maxPagesPerRun` to cap work per pass (resume via checkpoints)
- `isPulling` / `isPullingStream` for foreground busy UI

### Notes

- Handlers upsert into **your** app database; this package only stores checkpoints
- Requires Drift codegen artifacts (`lib/src/db/database.g.dart` is included)
