# offline_sync_pull example

Demonstrates:

1. **Paginated list sync** — `documents` feature (`page` 1 → 2 → 3…)
2. **Entity-batch detail sync** — `workflow` list then detail per workflow

Handlers are fakes. Data is stored in an in-memory `ExampleStore`. In your
app, handlers upsert into your `AppDatabase` (Drift).

## Run

```bash
cd packages/offline_sync_pull/example
flutter pub get
flutter run
```

Tap **Pull next batch** repeatedly to simulate background sync every 15
minutes (one bounded pass per tap). Checkpoints are shown from
`PullDatabase`.

## Map to your app

| Example | Your app |
|---|---|
| `ExampleStore` | `AppDatabase` + DAOs |
| `DocumentListPullHandler` | GET `/docs?page&limit` → `documentsDao.upsert` |
| `WorkflowDetailPullHandler` | GET `/workflows/:id` for each id from selector |
| `PullCoordinator.runFeature` | Workmanager / 15 min timer |

Pair with `offline_sync_core` for push + pull:

```dart
await engine.syncAll();
await pullCoordinator.runAll();
```
