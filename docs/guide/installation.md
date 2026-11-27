# Installation

Add the packages that match your sync direction, then continue to [Quick Start](/guide/quick-start).

Not sure which packages? See [Choosing Push or Pull](/guide/choosing-packages).

Packages are published on [pub.dev](https://pub.dev).

## pub.dev (recommended)

```yaml
dependencies:
  flutter_offline_sync_push: ^0.1.0
  flutter_offline_sync_pull_flutter: ^0.1.0
  flutter_offline_sync_ui: ^0.1.0 # optional
```

`flutter_offline_sync_push` and `flutter_offline_sync_pull_flutter` **re-export** their core packages — you usually do not need separate `flutter_offline_sync_core` / `flutter_offline_sync_pull` entries unless you use core-only (tests, CLI).

| Package | pub.dev |
| --- | --- |
| `flutter_offline_sync_core` | [pub.dev/packages/flutter_offline_sync_core](https://pub.dev/packages/flutter_offline_sync_core) |
| `flutter_offline_sync_push` | [pub.dev/packages/flutter_offline_sync_push](https://pub.dev/packages/flutter_offline_sync_push) |
| `flutter_offline_sync_pull` | [pub.dev/packages/flutter_offline_sync_pull](https://pub.dev/packages/flutter_offline_sync_pull) |
| `flutter_offline_sync_pull_flutter` | [pub.dev/packages/flutter_offline_sync_pull_flutter](https://pub.dev/packages/flutter_offline_sync_pull_flutter) |
| `flutter_offline_sync_ui` | [pub.dev/packages/flutter_offline_sync_ui](https://pub.dev/packages/flutter_offline_sync_ui) |

## Git dependency (optional)

Pin a **tag or commit**, not a moving branch, for production apps:

```yaml
dependencies:
  flutter_offline_sync_push:
    git:
      url: https://github.com/LidhinCS/flutter_offline_sync.git
      ref: v0.1.0
      path: packages/flutter_offline_sync_push

  flutter_offline_sync_pull_flutter:
    git:
      url: https://github.com/LidhinCS/flutter_offline_sync.git
      ref: v0.1.0
      path: packages/flutter_offline_sync_pull_flutter

  flutter_offline_sync_ui:
    git:
      url: https://github.com/LidhinCS/flutter_offline_sync.git
      ref: v0.1.0
      path: packages/flutter_offline_sync_ui
```

## Codegen

`flutter_offline_sync_core` and `flutter_offline_sync_pull` use Drift. Published packages include generated `.g.dart` files — consumers do **not** need to run build_runner for these packages.

Contributors changing Drift schemas in this repo:

```bash
dart run melos run build_runner
```

## Transitive dependencies

Flutter adapters bring:

- `workmanager`
- `connectivity_plus`
- Drift / SQLite (via core packages)

Ensure your app uses a compatible Flutter / Dart SDK (see each package’s `pubspec.yaml`).

## Choose packages

| Need | Add |
| --- | --- |
| Offline writes only | `flutter_offline_sync_push` |
| Server pull only | `flutter_offline_sync_pull_flutter` |
| Job status UI | `flutter_offline_sync_ui` |
| Unit tests without Flutter UI | `flutter_offline_sync_core` or `flutter_offline_sync_pull` directly |

## Next

1. [Quick Start](/guide/quick-start) — first working enqueue + `syncAll`  
2. [Push](/guide/push) / [Pull](/guide/pull) — deeper guides  
3. [Offline Notes example](/examples/) — full integration sample  
