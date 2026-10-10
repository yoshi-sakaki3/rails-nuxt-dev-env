// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: ['@nuxt/eslint'],
  css: ['~/assets/css/main.css'],

  runtimeConfig: {
    // Nuxt のサーバーから見た Rails の場所。環境変数 NUXT_API_BASE で上書きする（Docker では http://api:3000）
    apiBase: 'http://localhost:3400',
    public: {
      siteName: 'お知らせ（見本）',
    },
  },

  app: {
    head: {
      htmlAttrs: { lang: 'ja' },
      link: [{ rel: 'icon', href: '/favicon.ico' }],
    },
  },

  routeRules: {
    // 管理画面はブラウザ側だけで描く（検索エンジンに読ませる必要がなく、ログイン状態で中身が変わるため）
    '/admin/**': { ssr: false },
  },

  // Docker Desktop（Windows）では、保存しても変更の通知がコンテナに届かないので、定期的に見に行く
  watchers: {
    chokidar: { usePolling: true, interval: 500 },
  },
  vite: {
    server: {
      watch: { usePolling: true, interval: 500 },
    },
  },
  nitro: {
    watchOptions: { usePolling: true, interval: 500 },
  },
})
