# Publishing

Guidelines for publishing packages to pub.dev.

## Packages to publish

| Package | Typical consumer |
| --- | --- |
| `flutter_offline_sync_core` | Advanced / tests |
| `flutter_offline_sync_push` | Flutter apps (push) |
| `flutter_offline_sync_pull` | Advanced / tests |
| `flutter_offline_sync_pull_flutter` | Flutter apps (pull) |
| `flutter_offline_sync_ui` | Optional UI |

Publish **core / pull first**, then push/pull flutter adapters and UI (they depend on the hosted versions).

## Why these names

`offline_sync_core` and `offline_sync_flutter` are already taken on pub.dev by unrelated packages. This suite uses the `flutter_offline_sync_*` prefix (aligned with the GitHub repo).

## Checklist (each release)

1. Confirm pub.dev names are free (or already owned by you)
2. Bump `version` in each package `pubspec.yaml` (semver)
3. Update each package `CHANGELOG.md` and `docs/changelog.md`
4. Confirm `LICENSE` (MIT), `README.md`, homepage / repository / topics
5. Ensure Drift `.g.dart` files are up to date and committed
6. `dart pub get` at repo root (workspace)
7. `dart run melos run analyze` and `dart run melos run test`
8. Dry-run (dependency order):

```bash
cd packages/flutter_offline_sync_core && dart pub publish --dry-run
cd ../flutter_offline_sync_pull && dart pub publish --dry-run
cd ../flutter_offline_sync_push && dart pub publish --dry-run
cd ../flutter_offline_sync_pull_flutter && dart pub publish --dry-run
cd ../flutter_offline_sync_ui && dart pub publish --dry-run
```

9. Publish in the same order (omit `--dry-run`)
10. After first publish of core/pull, remove `dependency_overrides` from push/ui **examples**
11. Git tag: `v0.1.0`
12. Deploy docs site; update installation snippets

## Workspace resolution

Packages use `resolution: workspace` and version constraints between suite members. Local `dart pub get` at the monorepo root resolves siblings from the workspace. Published consumers resolve from pub.dev.

## Docs site

Deploy from `docs/` via GitHub Actions. Update the changelog page after each release.

## Versioning

- Semver per package
- Breaking handler/coordinator API → major bump
- Coordinate releases when core + flutter packages must stay compatible
