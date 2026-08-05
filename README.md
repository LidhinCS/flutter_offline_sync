# offline_sync

Offline-first sync monorepo for Flutter/Dart apps: write queue (push), pull
coordinator (read), Flutter adapters, and UI widgets.

## Packages

| Package | Role |
|---|---|
| `offline_sync_core` | Write queue — jobs, steps, `SyncEngine`, Drift outbox |
| `offline_sync_flutter` | Workmanager + connectivity adapters for push sync |
| `offline_sync_pull` | Pull coordinator — paginated lists, entity batches, checkpoints |
| `offline_sync_pull_flutter` | Workmanager + connectivity adapters for pull sync |
| `offline_sync_ui` | Flutter widgets wired to sync job streams |

Each package has an example app under `packages/<name>/example`.

## Setup

```bash
dart pub get
```

Or via Melos:

```bash
dart run melos run get
```

## Melos scripts

Scripts are defined in the root `pubspec.yaml` under `melos.scripts`. Run them
with `dart run melos run <script>` from the repository root.

List all scripts:

```bash
dart run melos run --list
```

| Command | Description |
|---|---|
| `dart run melos run get` | Resolve dependencies for the whole workspace |
| `dart run melos run analyze` | `dart analyze` on each workspace package |
| `dart run melos run test` | `flutter test` in packages with a `test/` directory |
| `dart run melos run format:check` | Verify formatting (`--set-exit-if-changed`) |
| `dart run melos run format:fix` | Apply `dart format` across `packages/` |
| `dart run melos run build_runner` | Drift codegen in `offline_sync_core` and `offline_sync_pull` |
| `dart run melos run clean` | `flutter clean` on Flutter packages |
| `dart run melos run ci` | Runs `analyze`, then `test`, then `format:check` |

### Examples

```bash
# Run the full CI pipeline
dart run melos run ci

# Regenerate Drift code after schema changes
dart run melos run build_runner

# Run tests only
dart run melos run test
```

## Examples

```bash
cd packages/offline_sync_core/example && flutter run
cd packages/offline_sync_flutter/example && flutter run
cd packages/offline_sync_pull/example && flutter run
cd packages/offline_sync_pull_flutter/example && flutter run
cd packages/offline_sync_ui/example && flutter run
```

## Codegen

After changing Drift schemas in `offline_sync_core` or `offline_sync_pull`:

```bash
dart run melos run build_runner
```
