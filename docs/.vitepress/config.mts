import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'

const github = 'https://github.com/LidhinCS/flutter_offline_sync'
const buyMeACoffee = 'https://buymeacoffee.com/lidhincs'
const buyMeACoffeeButton =
  'https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png'

export default withMermaid(
  defineConfig({
    title: 'flutter_offline_sync',
    description:
      'Offline-first sync for Flutter: push write queue, pull coordinator, and UI widgets.',
    base: '/flutter_offline_sync/',
    cleanUrls: true,
    // Keep the dark/light toggle, but prefer light for first-time visitors.
    // (VitePress types only document initialValue: 'dark'; 'light' works at runtime.)
    appearance: {
      initialValue: 'light',
    } as { initialValue: 'dark' },
    lastUpdated: true,
    head: [
      ['link', { rel: 'icon', href: '/flutter_offline_sync/favicon.ico' }],
    ],
    // Mermaid 11 pulls in CJS packages (e.g. fastdom) that break Vite ESM without
    // prebundling — that surfaces as a blank white docs site. Pin Mermaid 10 in
    // package.json and prebundle it here.
    vite: {
      optimizeDeps: {
        include: ['mermaid'],
      },
      ssr: {
        noExternal: ['mermaid', 'vitepress-plugin-mermaid'],
      },
    },
    mermaid: {
      securityLevel: 'loose',
      startOnLoad: false,
    },
    themeConfig: {
      logo: { text: 'flutter_offline_sync' },
      nav: [
        { text: 'Guide', link: '/guide/introduction', activeMatch: '/guide/' },
        { text: 'Packages', link: '/packages/', activeMatch: '/packages/' },
        { text: 'Examples', link: '/examples/', activeMatch: '/examples/' },
        { text: 'Advanced', link: '/advanced/', activeMatch: '/advanced/' },
        { text: 'Changelog', link: '/changelog' },
        {
          text: 'GitHub',
          link: github,
        },
      ],
      sidebar: {
        '/guide/': [
          {
            text: 'Getting started',
            items: [
              { text: 'Introduction', link: '/guide/introduction' },
              { text: 'Installation', link: '/guide/installation' },
              { text: 'Quick Start', link: '/guide/quick-start' },
              { text: 'Choosing Push or Pull', link: '/guide/choosing-packages' },
            ],
          },
          {
            text: 'Fundamentals',
            items: [
              { text: 'Core concepts', link: '/guide/core-concepts' },
              { text: 'Architecture', link: '/guide/architecture' },
            ],
          },
          {
            text: 'Push & Pull',
            items: [
              { text: 'Push (write queue)', link: '/guide/push' },
              { text: 'Pull (read coordinator)', link: '/guide/pull' },
              {
                text: 'Foreground & background',
                link: '/guide/foreground-background',
              },
            ],
          },
          {
            text: 'Integration',
            items: [
              { text: 'Clean architecture', link: '/guide/clean-architecture' },
              { text: 'Drift & App database', link: '/guide/drift' },
              { text: 'Authentication', link: '/guide/authentication' },
              { text: 'UI widgets', link: '/guide/ui' },
            ],
          },
          {
            text: 'Help',
            items: [
              { text: 'Troubleshooting', link: '/guide/troubleshooting' },
              { text: 'FAQ', link: '/guide/faq' },
            ],
          },
        ],
        '/packages/': [
          {
            text: 'Packages',
            items: [
              { text: 'Overview', link: '/packages/' },
              {
                text: 'flutter_offline_sync_core',
                link: '/packages/flutter_offline_sync_core',
              },
              {
                text: 'flutter_offline_sync_push',
                link: '/packages/flutter_offline_sync_push',
              },
              {
                text: 'flutter_offline_sync_pull',
                link: '/packages/flutter_offline_sync_pull',
              },
              {
                text: 'flutter_offline_sync_pull_flutter',
                link: '/packages/flutter_offline_sync_pull_flutter',
              },
              {
                text: 'flutter_offline_sync_ui',
                link: '/packages/flutter_offline_sync_ui',
              },
            ],
          },
        ],
        '/examples/': [
          {
            text: 'Examples',
            items: [{ text: 'Overview', link: '/examples/' }],
          },
        ],
        '/advanced/': [
          {
            text: 'Advanced',
            items: [{ text: 'Overview', link: '/advanced/' }],
          },
        ],
      },
      socialLinks: [{ icon: 'github', link: github }],
      editLink: {
        pattern: `${github}/edit/main/docs/:path`,
        text: 'Edit this page on GitHub',
      },
      footer: {
        message: `Released under the MIT License.<div class="bmc-footer-row"><a href="${buyMeACoffee}" target="_blank" rel="noreferrer"><img src="${buyMeACoffeeButton}" alt="Buy me a coffee" class="bmc-footer-button" /></a></div>`,
        copyright: 'Copyright © Lidhin',
      },
      search: {
        provider: 'local',
      },
    },
  }),
)
