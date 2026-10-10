// 管理画面のログイン。合言葉が正しければ、ブラウザの JavaScript からは読めない Cookie に入れる。
// 以後、管理用の API は Nuxt のサーバーがこの Cookie を見て、Rails に合言葉を付けて取り次ぐ。
export default defineEventHandler(async (event) => {
  const body = await readBody<{ token?: unknown }>(event)
  const token = typeof body?.token === 'string' ? body.token.trim() : ''

  if (!(await isValidAdminToken(event, token))) {
    throw createError({
      statusCode: 401,
      statusMessage: 'Unauthorized',
      data: { error: '合言葉が違います' },
    })
  }

  setCookie(event, ADMIN_COOKIE, token, {
    httpOnly: true, // JavaScript から読めない（画面に悪いスクリプトが入り込んでも盗まれにくい）
    sameSite: 'strict', // ほかのサイトからのリクエストには付けない（CSRF 対策）
    secure: !import.meta.dev, // 本番では HTTPS のときだけ送る
    path: '/',
    maxAge: 60 * 60 * 8,
  })
  return { ok: true }
})
