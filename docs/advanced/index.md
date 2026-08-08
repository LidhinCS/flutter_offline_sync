# Advanced topics

Deeper topics beyond the integration guides.

## Topics covered in guides

- Partial retry and `isOutputStillValid` — [Push](/guide/push)
- Conflict resolution — [Push](/guide/push)
- Cross-job dependencies — package README in `offline_sync_core`
- Bounded pull runs (`maxPagesPerRun`) — [Pull](/guide/pull)
- WAL and multi-isolate DB access — [Foreground & background](/guide/foreground-background)

## Local development

Clone the repository and use Melos scripts from the root `pubspec.yaml`:

```bash
dart pub get
dart run melos run test
dart run melos run analyze
dart run melos run build_runner
```

## Contributing

- Open PRs against [GitHub](https://github.com/LidhinCS/flutter_offline_sync)
- Run `dart run melos run ci` before submitting
- Update docs in `docs/` when changing public behavior

## Publishing

See [Publishing](/advanced/publishing).
