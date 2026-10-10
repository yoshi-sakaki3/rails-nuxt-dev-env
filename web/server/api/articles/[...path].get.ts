// 公開側の記事 API。Rails の /api/articles... にそのまま取り次ぐ。
// ブラウザは Nuxt（同じ住所）だけを呼べばよいので、CORS の設定がいらない。
export default defineEventHandler((event) => {
  return proxyRequest(event, railsUrl(event, event.path))
})
