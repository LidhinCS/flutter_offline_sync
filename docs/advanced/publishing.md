# Publishing

Guidelines for publishing packages to pub.dev.

## Packages to publish

| Package | Typical consumer |
| --- | --- |
| `offline_sync_core` | Advanced / tests |
| `offline_sync_flutter` | Flutter apps (push) |
| `offline_sync_pull` | Advanced / tests |
| `offline_sync_pull_flutter` | Flutter apps (pull) |
| `offline_sync_ui` | Optional UI |

## Before first publish

1. Root and per-package **LICENSE** (MIT)
2. Remove `publish_to: none` on packages you ship
3. `CHANGELOG.md` per package
4. `homepage` and `documentation` in each `pubspec.yaml`:

```yaml
homepage: https://lidhin.github.io/flutter_offline_sync/
documentation: https://lidhin.github.io/flutter_offline_sync/guide/introduction
repository: https://github.com/LidhinCS/flutter_offline_sync
issue_tracker: https://github.com/LidhinCS/flutter_offline_sync/issues
```

5. Run `dart pub publish --dry-run` in each package directory
6. Commit generated Drift `.g.dart` files or document codegen for consumers
7. Tag release: `v0.1.0` — consumers should pin Git `ref` to tags

## Workspace resolution

Development packages may use `resolution: workspace`. Published packages should expose normal pub.dev version constraints for consumers.

## Docs site

Deploy from `docs/` via GitHub Actions. Update changelog page after each release.

## Versioning

- Semver per package
- Breaking handler/coordinator API → major bump
- Coordinate releases when core + flutter packages must stay compatible
