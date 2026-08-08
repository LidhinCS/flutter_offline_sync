# Installation

Packages are published from the [flutter_offline_sync](https://github.com/LidhinCS/flutter_offline_sync) monorepo.

## Git dependency (current)

Pin a **tag or commit**, not a moving branch, for production apps:

```yaml
dependencies:
  offline_sync_flutter:
    git:
      url: https://github.com/LidhinCS/flutter_offline_sync.git
      ref: main # prefer v0.1.0 tag when released
      path: packages/offline_sync_flutter

  offline_sync_pull_flutter:
    git:
      url: https://github.com/LidhinCS/flutter_offline_sync.git
      ref: main
      path: packages/offline_sync_pull_flutter

  offline_sync_ui:
    git:
      url: https://github.com/LidhinCS/flutter_offline_sync.git
      ref: main
      path: packages/offline_sync_ui
```

`offline_sync_flutter` and `offline_sync_pull_flutter` **re-export** their core packages — you usually do not need separate `offline_sync_core` / `offline_sync_pull` entries unless you use core-only (tests, CLI).

## pub.dev (after publish)

```yaml
dependencies:
  offline_sync_flutter: ^0.1.0
  offline_sync_pull_flutter: ^0.1.0
  offline_sync_ui: ^0.1.0
```

## Codegen

`offline_sync_core` and `offline_sync_pull` use Drift. After cloning the monorepo:

```bash
dart run melos run build_runner
```

Consumers using Git deps get pre-built `.g.dart` from the repo once checked in, or run build_runner in those package paths if needed.

## Transitive dependencies

Flutter adapters bring:

- `workmanager`
- `connectivity_plus`
- Drift / SQLite (via core packages)

Ensure your app already uses compatible Flutter SDK (`>=3.12`).

## Choose packages

| Need | Add |
| --- | --- |
| Offline writes only | `offline_sync_flutter` |
| Server pull only | `offline_sync_pull_flutter` |
| Job status UI | `offline_sync_ui` |
| Unit tests without Flutter | `offline_sync_core` or `offline_sync_pull` directly |

Next: [Push guide](/guide/push) or [Pull guide](/guide/pull).
