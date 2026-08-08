# offline_sync documentation

VitePress site for the offline_sync packages.

## Local development

```bash
cd docs
npm install
npm run dev
```

Open the URL shown in the terminal (usually `http://localhost:5173/flutter_offline_sync/`).

## Production build

```bash
npm run build
npm run preview
```

## Deploy

Pushes to `main` that touch `docs/` trigger [.github/workflows/docs.yml](../.github/workflows/docs.yml) → GitHub Pages.

Enable **GitHub Pages** in repo settings: Source = **GitHub Actions**.

Site URL (default): `https://lidhin.github.io/flutter_offline_sync/`

## Structure

| Path | Content |
| --- | --- |
| `guide/` | Integration guides |
| `packages/` | Per-package overview |
| `examples/` | Example apps |
| `advanced/` | Publishing and contributor notes |
