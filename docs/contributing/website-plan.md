# Documentation site plan — offline_sync

Plan for a public docs site before publishing packages to pub.dev (and/or Git
as a package suite). Target quality: similar to [Bloc](https://bloclibrary.dev),
[Drift](https://drift.simonbinder.eu), or [Mason](https://docs.brickhub.dev) —
conceptual overview, integration guides, and API reference links.

---

## 1. Goals

| Goal | Success metric |
|---|---|
| Explain **what** offline_sync is in under 2 minutes | Landing page + architecture diagram |
| Show **how push + pull** fit together | Dedicated architecture section |
| Enable integration without reading the whole repository | Step-by-step guides per app profile |
| Support **pub.dev** discovery | `homepage` + `documentation` URLs in every `pubspec.yaml` |
| Reduce support questions | Troubleshooting + FAQ |
| Look credible for adoption | Polished UI, search, mobile-friendly, changelog |

**Audience**

- Flutter developers adding offline-first to an existing app
- Teams using Dio + Drift + clean architecture
- Readers who may consume via **Git path deps** today, **pub.dev** later

---

## 2. Recommended stack

| Layer | Recommendation | Why |
|---|---|---|
| **Site generator** | [VitePress](https://vitepress.dev/) or [Docusaurus](https://docusaurus.io/) | Markdown-first, search, versioning, GitHub Pages deploy |
| **Hosting** | GitHub Pages (`gh-pages` or `docs/` on `main`) | Free, matches GitHub repo; custom domain optional |
| **Domain** | `offline-sync.dev` or `docs.offlinesync.*` or GitHub default | CNAME in repo settings |
| **API reference** | pub.dev dartdoc + link from site | Avoid maintaining duplicate API docs |
| **Diagrams** | Mermaid in Markdown (VitePress native) | Architecture, push vs pull, data stores |
| **Analytics** | Plausible or none initially | Privacy-friendly |

**Repo layout (proposed)**

```text
flutter_offline_sync/
  docs/                          # VitePress root OR docusaurus website/
    .vitepress/config.ts
    index.md                     # Landing
    guide/
    packages/
    examples/
    advanced/
  packages/                      # existing
  README.md                      # short pointer → docs site URL
```

**Alternative:** [docs.page](https://docs.page) — zero build, Markdown in `docs/`, fast MVP; migrate to VitePress when content grows.

**Recommendation:** Start **VitePress** in `docs/` — good balance of polish vs effort for a multi-package guide.

---

## 3. Site information architecture

### Top navigation

```text
Home | Guides | Packages | Examples | Advanced | Changelog | GitHub
```

### Page tree

#### **Home** (`/`)

- Hero: “Offline-first sync for Flutter — push queue + pull coordinator”
- Problem statement (flat outbox vs job DAG, read vs write split)
- Package matrix (5 packages, one-line role, install snippet)
- “Choose your path” cards:
  - Push only → `offline_sync_flutter`
  - Pull only → `offline_sync_pull_flutter`
  - Full stack → both + optional `offline_sync_ui`
- Link to live examples / repo example apps
- Badges: pub.dev versions (when published), CI, license

#### **Guides** (`/guide/`)

| Page | Content source / notes |
|---|---|
| **Introduction** | Why offline_sync exists; comparison to “just use Drift” |
| **Core concepts** | Job, Step, Handler, Feature, Checkpoint, Coordinator |
| **Architecture** | Three DBs diagram: App DB vs Sync DB vs Pull DB |
| **Push (write path)** | From `offline_sync_core` README |
| **Pull (read path)** | From `offline_sync_pull` README |
| **Foreground + background** | Workmanager, connectivity, isolate rules |
| **Clean architecture** | Feature folders, handlers, repositories, DI |
| **Drift coexistence** | AppDatabase + package DBs, WAL, handlers upsert |
| **Authentication** | Secure storage, foreground vs background Dio |
| **UI widgets** | `offline_sync_ui` scope, badge, banner |
| **Troubleshooting** | drift multi-db warnings, `getIt` in background, iOS Keychain |

#### **Packages** (`/packages/`)

One page per published package:

| Package | Sections on page |
|---|---|
| `offline_sync_core` | Install, when to use alone, API overview, link to dartdoc |
| `offline_sync_flutter` | Install, Workmanager setup, exports |
| `offline_sync_pull` | Install, step types, checkpoints |
| `offline_sync_pull_flutter` | Install, mirror of flutter adapter |
| `offline_sync_ui` | Widget catalog, screenshots |

Each page: `pubspec` dependency snippet (pub.dev + Git path fallback), minimal quick start, link to full guide.

#### **Examples** (`/examples/`)

| Example | What it demonstrates |
|---|---|
| Core only | Handlers, enqueue, `syncAll()` |
| Flutter push | Coordinator + background |
| Pull | Paginated list + entity batch |
| Pull flutter | Connectivity + Workmanager pull |
| UI | Badges, banners, list tiles |
| **Full app recipe** | Push then pull on reconnect, Injectable modules |

Embed or link to `packages/*/example` with `flutter run` instructions.

#### **Advanced** (`/advanced/`)

- Cross-job dependencies + field mapping
- Retry policy, conflict handling, idempotency keys
- `maxPagesPerRun` / bounded pulls
- Custom retry / `isOutputStillValid`
- Melos scripts for contributors
- Publishing / versioning policy

#### **Changelog** (`/changelog`)

- Aggregated from package `CHANGELOG.md` files (manual or scripted)
- Semver + migration notes per release

#### **Contributing** (optional)

- Link to root README, Melos scripts, PR expectations

---

## 4. Key content to write (not in READMEs yet)

Priority content gaps to fill for a “big package” feel:

1. **Architecture diagram** — push vs pull, three databases, handler boundaries
2. **Decision guide** — “Do I need pull?” / “Do I need UI package?”
3. **Integration checklist** — numbered steps from zero to production
4. **Background isolate checklist** — top-level factories, no GetIt, token read
5. **Injectable module templates** — `SyncModule`, `PullModule`, `DatabaseModule`
6. **Migration** — from naive outbox or from online-only Dio
7. **pub.dev vs Git** — `resolution: workspace` caveat for external consumers
8. **Platform setup** — Android Workmanager, iOS background, permissions

Reuse heavily from existing package READMEs; site adds **narrative flow** and **diagrams**.

---

## 5. Visual & UX standards

- **Brand:** name `offline_sync`, consistent logo/wordmark on landing
- **Code blocks:** Dart only, copy button, light/dark theme
- **Diagrams:** Mermaid for:
  - Write path: UI → enqueue → SyncEngine → handler → API → App DB
  - Read path: Coordinator → checkpoint → handler → API → App DB
  - Full reconnect: `syncAll()` then `runAll()`
- **Screenshots:** 2–3 from `offline_sync_ui` example and pull demo
- **Package cards:** icon + install one-liner on home

Reference sites for tone/structure:

- https://bloclibrary.dev/flutter/blocconcepts
- https://drift.simonbinder.eu/docs/getting-started/
- https://riverpod.dev/docs/introduction/why_riverpod

---

## 6. pub.dev publishing alignment

Before or alongside first publish:

| Task | Detail |
|---|---|
| **Root LICENSE** | Single license file (MIT matches some packages) |
| **Per-package LICENSE** | All packages aligned |
| **`publish_to`** | Remove `publish_to: none` on packages you publish |
| **`homepage`** | `https://your-docs-site/` |
| **`repository`** | `https://github.com/LidhinCS/flutter_offline_sync` |
| **`documentation`** | `https://your-docs-site/guide/introduction` |
| **`issue_tracker`** | GitHub issues URL |
| **Description** | 60–180 chars per package, distinct per package |
| **Changelog** | `CHANGELOG.md` per package for pub.dev “changelog” tab |
| **Scores** | `dart doc` / pana — document minimum 130/160 targets |

**Publishing strategy**

| Option | Pros |
|---|---|
| **5 separate pub.dev packages** | Matches imports today; clear deps |
| **Git-only + docs** | Simpler until API stable |
| **Hybrid** | Publish `core` + `flutter` first; pull/ui follow in 0.2 |

Document on site which install path you recommend at each phase.

**Git dependency snippet**

```yaml
offline_sync_flutter:
  git:
    url: https://github.com/LidhinCS/flutter_offline_sync.git
    ref: v0.1.0   # tag, not moving main
    path: packages/offline_sync_flutter
```

**pub.dev snippet (after publish)**

```yaml
offline_sync_flutter: ^0.1.0
```

---

## 7. CI/CD for docs

```yaml
# .github/workflows/docs.yml (outline)
on:
  push:
    branches: [main]
    paths: ['docs/**', 'packages/**/README.md']

jobs:
  deploy:
    - npm ci && npm run docs:build   # or pnpm
    - deploy to gh-pages / Cloudflare Pages
```

- **Preview:** VitePress deploy previews on PRs (optional)
- **Link check:** `lychee` or built-in on CI
- **Versioning:** Later, `/v0.1/` prefix when breaking changes (VitePress `rewrites`)

---

## 8. Implementation phases

### Phase 0 — Prep (1–2 days)

- [ ] Choose domain or GitHub Pages URL
- [ ] Add root `LICENSE`, unify package metadata
- [ ] Extract architecture diagram (Mermaid) into `docs/`
- [ ] Shorten root `README.md` → link to docs site

### Phase 1 — MVP site (3–5 days)

- [ ] VitePress scaffold in `docs/`
- [ ] Home + Introduction + Architecture + Push guide + Pull guide
- [ ] Package index with install snippets
- [ ] Deploy to GitHub Pages
- [ ] Set `homepage` / `documentation` in pubspecs (even pre-publish)

### Phase 2 — Integration depth (3–5 days)

- [ ] Full integration guide (DI, Drift, Dio, Workmanager)
- [ ] Background isolate + auth page
- [ ] Examples index linking to example apps
- [ ] Troubleshooting + FAQ
- [ ] Screenshots from examples

### Phase 3 — Publish-ready (2–3 days)

- [ ] Per-package CHANGELOG + version policy doc
- [ ] pub.dev dry-run (`dart pub publish --dry-run` per package)
- [ ] API links to pub.dev documentation
- [ ] Changelog page on site
- [ ] Announcement / README badges

### Phase 4 — Polish (ongoing)

- [ ] Search tuning, sidebar polish
- [ ] Optional: real-world integration case study
- [ ] Optional: migration guides from other libs
- [ ] Versioned docs when 1.0 approaches

**Total estimate:** ~2 weeks part-time for Phases 0–3.

---

## 9. Content ownership map

| Existing asset | Site section |
|---|---|
| `packages/offline_sync_core/README.md` | Guide: Push, Advanced: retry/conflict |
| `packages/offline_sync_flutter/README.md` | Guide: Background, Package page |
| `packages/offline_sync_pull/README.md` | Guide: Pull, entity batch |
| `packages/offline_sync_pull_flutter/README.md` | Package page |
| `packages/offline_sync_ui/README.md` | Guide: UI, screenshots |
| Root `README.md` | Contributor setup, Melos |
| App integration patterns | Guide: Clean architecture (optional) |

**Rule:** READMEs stay as quick reference; **site owns the learning path**. README links to `documentation` URL for depth.

---

## 10. Success checklist before announcing

- [ ] Landing explains push vs pull without opening GitHub
- [ ] At least one **end-to-end** guide (enqueue → sync → UI badge)
- [ ] At least one **pull** guide (list + detail batch)
- [ ] Background setup documented with full `callbackDispatcher` sample
- [ ] “Three databases” section explicit (App vs Sync vs Pull)
- [ ] Install works from documented `pubspec` (test in fresh project)
- [ ] Mobile-readable, search works
- [ ] All package pages have correct `homepage` links
- [ ] License visible in footer

---

## 11. Open decisions (resolve before build)

1. **Public name:** `offline_sync` vs `offline_sync_flutter` as marketing name → recommend **offline_sync** umbrella
2. **Custom domain** vs `lidhin.github.io/flutter_offline_sync`
3. **Publish all 5 packages at 0.1.0** or stagger core/flutter first
4. **Git `ref: main`** vs tagged releases for consumers (recommend tags)
5. **Remove `resolution: workspace`** on published packages or document path-only Git consumption
6. **Author / publisher** consistency (`publisher: lidhin.com` in pubspecs)

---

## 12. Quick start command (for implementers)

When executing Phase 1:

```bash
cd flutter_offline_sync
npm create vitepress@latest docs
# configure base: '/flutter_offline_sync/' or custom domain
# add GitHub Actions deploy workflow
```

Or Docusaurus:

```bash
npx create-docusaurus@latest docs classic
```

---

## Summary

Build a **VitePress (or Docusaurus) site** in `docs/`, deploy to **GitHub Pages**, structure as **Guides → Packages → Examples → Advanced**. Reuse package READMEs but add **architecture diagrams**, **integration checklists**, and **background/DI** content that READMEs don’t cover. Wire **homepage/documentation** fields before pub.dev publish. Ship MVP in ~1 week, publish-ready docs in ~2 weeks.
