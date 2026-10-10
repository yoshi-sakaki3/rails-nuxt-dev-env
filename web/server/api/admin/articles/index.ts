// 管理用の記事 API の入口（一覧の GET と、追加の POST）
export default defineEventHandler((event) => proxyAdmin(event))
