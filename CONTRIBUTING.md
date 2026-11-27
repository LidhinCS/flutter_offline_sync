# Contributing

## Setup

```bash
dart pub get
dart run melos run get
```

## Checks

```bash
dart run melos run analyze
dart run melos run test
dart run melos run format:check
```

After Drift schema changes in `flutter_offline_sync_core` or `flutter_offline_sync_pull`:

```bash
dart run melos run build_runner
```

## Docs

```bash
cd docs && npm install && npm run dev
```

Do not publish packages from a fork without coordinating with maintainers.
