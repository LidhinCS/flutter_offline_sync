# Offline Notes — full-stack example

Teaching app that wires **push**, **pull**, Flutter coordinators, and UI widgets
around a real Drift **AppDatabase**.

## Run

```bash
cd examples/notes_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## What to try

1. **Notes** — list comes from App DB (seeded by pull on startup).
2. **Create** — saves offline (optimistic row + outbox job). Toggle attachment for a two-step DAG.
3. Tap **Sync** — push (`syncAll`) then pull (`runAll`).
4. **Outbox** — SyncDatabase jobs with retry via `SyncJobListTile`.
5. **Guide** — three databases and folder layout.

## Architecture (short)

| Database | File | Role |
| --- | --- | --- |
| AppDatabase | `app.sqlite` | Notes you display |
| SyncDatabase | `sync_core.sqlite` | Outbox jobs/steps |
| PullDatabase | `flutter_offline_sync_pull.sqlite` | Pull checkpoints |

```text
lib/
  core/database|sync|background
  features/notes/{domain,data,presentation}
```

Domain has **no** `flutter_offline_sync_*` imports. Handlers live under `data/sync/`.

Fake network: `FakeNotesApi` (in-memory). Background Workmanager is initialized
with `registerPeriodicTask: false` (same as package examples).
