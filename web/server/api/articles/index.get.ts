// 公開側の記事一覧。Rails の /api/articles に取り次ぐ（?page= もそのまま渡る）
export default defineEventHandler((event) => {
  return proxyRequest(event, railsUrl(event, event.path))
})
