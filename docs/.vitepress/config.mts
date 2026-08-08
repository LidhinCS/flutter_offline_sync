import { defineConfig } from 'vitepress'

const github = 'https://github.com/LidhinCS/flutter_offline_sync'
const buyMeACoffee = 'https://buymeacoffee.com/lidhincs'

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
      {
        text: 'Buy me a coffee',
        link: buyMeACoffee,
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
    socialLinks: [
      { icon: 'github', link: github },
      {
        icon: {
          svg: '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>Buy Me A Coffee</title><path d="M20.216 6.415l-.132-.666c-.119-.598-.388-1.163-1.127-1.163H6.52l-.19-1.006c-.069-.364-.186-.7-.362-.98C5.55 2.108 5.0 1.8 4.2 1.8H2.3a.75.75 0 0 0 0 1.5h1.9c.25 0 .35.08.42.2.06.1.12.28.16.5l2.18 10.92c.2 1.02.88 1.7 1.92 1.7h9.86a.75.75 0 0 0 0-1.5H8.88c-.35 0-.5-.2-.56-.5l-.2-1h9.7c.9 0 1.6-.55 1.8-1.4l1.2-5.5c.1-.5.05-.9-.1-1.2zm-1.4.9l-1.2 5.5c-.05.25-.2.35-.4.35H8.0l-1.2-6h10.4c.2 0 .25.05.25.1.02.05 0 .15-.05.35zM8.5 18.5a1.75 1.75 0 1 0 0 3.5 1.75 1.75 0 0 0 0-3.5zm7.5 0a1.75 1.75 0 1 0 0 3.5 1.75 1.75 0 0 0 0-3.5z"/></svg>',
        },
        link: buyMeACoffee,
        ariaLabel: 'Buy me a coffee',
      },
    ],
    editLink: {
      pattern: `${github}/edit/main/docs/:path`,
      text: 'Edit this page on GitHub',
    },
    footer: {
      message:
        'Released under the MIT License. · <a href="https://buymeacoffee.com/lidhincs" target="_blank" rel="noreferrer">Buy me a coffee</a>',
      copyright: 'Copyright © Lidhin',
    },
    search: {
      provider: 'local',
    },
  },
})
