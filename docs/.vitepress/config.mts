import { defineConfig } from 'vitepress'

const github = 'https://github.com/LidhinCS/flutter_offline_sync'
const buyMeACoffee = 'https://buymeacoffee.com/lidhincs'
const buyMeACoffeeButton =
  'https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&slug=lidhincs&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff'

export default defineConfig({
  title: 'offline_sync',
  description:
    'Offline-first sync for Flutter: push write queue, pull coordinator, and UI widgets.',
  base: '/flutter_offline_sync/',
  cleanUrls: true,
  lastUpdated: true,
  head: [
    ['link', { rel: 'icon', href: '/flutter_offline_sync/favicon.ico' }],
  ],
  themeConfig: {
    logo: { text: 'offline_sync' },
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
            { text: 'Core concepts', link: '/guide/core-concepts' },
            { text: 'Architecture', link: '/guide/architecture' },
          ],
        },
        {
          text: 'Sync paths',
          items: [
            { text: 'Push (write queue)', link: '/guide/push' },
            { text: 'Pull (read coordinator)', link: '/guide/pull' },
            { text: 'Foreground & background', link: '/guide/foreground-background' },
          ],
        },
        {
          text: 'Integration',
          items: [
            { text: 'Installation', link: '/guide/installation' },
            { text: 'Clean architecture', link: '/guide/clean-architecture' },
            { text: 'Drift & App database', link: '/guide/drift' },
            { text: 'Authentication', link: '/guide/authentication' },
            { text: 'UI widgets', link: '/guide/ui' },
            { text: 'Troubleshooting', link: '/guide/troubleshooting' },
          ],
        },
      ],
      '/packages/': [
        {
          text: 'Packages',
          items: [
            { text: 'Overview', link: '/packages/' },
            { text: 'offline_sync_core', link: '/packages/offline_sync_core' },
            { text: 'offline_sync_flutter', link: '/packages/offline_sync_flutter' },
            { text: 'offline_sync_pull', link: '/packages/offline_sync_pull' },
            { text: 'offline_sync_pull_flutter', link: '/packages/offline_sync_pull_flutter' },
            { text: 'offline_sync_ui', link: '/packages/offline_sync_ui' },
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
          items: [
            { text: 'Overview', link: '/advanced/' },
            { text: 'Publishing', link: '/advanced/publishing' },
            { text: 'Website plan', link: '/contributing/website-plan' },
          ],
        },
      ],
    },
    socialLinks: [{ icon: 'github', link: github }],
    editLink: {
      pattern: `${github}/edit/main/docs/:path`,
      text: 'Edit this page on GitHub',
    },
    footer: {
      message: `Released under the MIT License.<br/><a href="${buyMeACoffee}" target="_blank" rel="noreferrer"><img src="${buyMeACoffeeButton}" alt="Buy me a coffee" height="45" style="margin-top: 10px" /></a>`,
      copyright: 'Copyright © Lidhin',
    },
    search: {
      provider: 'local',
    },
  },
})
