// 管理用の記事 API（1件の取得・変更・削除）。Cookie の合言葉を付けて、Rails に取り次ぐ
export default defineEventHandler((event) => proxyAdmin(event))
