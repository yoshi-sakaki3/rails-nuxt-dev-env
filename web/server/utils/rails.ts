import type { H3Event } from 'h3'

/** 管理用の合言葉を入れる Cookie の名前 */
export const ADMIN_COOKIE = 'admin_token'

/** Rails の URL を作る（path は /api/... の形） */
export function railsUrl(event: H3Event, path: string): string {
  return `${useRuntimeConfig(event).apiBase}${path}`
}

/** 合言葉が正しいかを Rails に確かめる */
export async function isValidAdminToken(
  event: H3Event,
  token: string | undefined,
): Promise<boolean> {
  if (!token) return false
  try {
    await $fetch.raw(railsUrl(event, '/api/admin/session'), {
      headers: { Authorization: `Bearer ${token}` },
    })
    return true
  } catch {
    return false
  }
}

/**
 * 管理用の API を Rails に取り次ぐ。Cookie の合言葉を Authorization ヘッダーに付ける。
 * Cookie がなければ、Rails を呼ばずに 401 を返す。
 */
export function proxyAdmin(event: H3Event) {
  const token = getCookie(event, ADMIN_COOKIE)
  if (!token) {
    throw createError({
      statusCode: 401,
      statusMessage: 'Unauthorized',
      data: { error: 'ログインしてください' },
    })
  }
  return proxyRequest(event, railsUrl(event, event.path), {
    headers: { Authorization: `Bearer ${token}` },
  })
}
