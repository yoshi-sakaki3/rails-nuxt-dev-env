const TOKYO = 'Asia/Tokyo'

const jaDate = new Intl.DateTimeFormat('ja-JP', {
  timeZone: TOKYO,
  year: 'numeric',
  month: 'long',
  day: 'numeric',
})

const jaDateTime = new Intl.DateTimeFormat('ja-JP', {
  timeZone: TOKYO,
  year: 'numeric',
  month: '2-digit',
  day: '2-digit',
  hour: '2-digit',
  minute: '2-digit',
  hourCycle: 'h23',
})

/** 2026-10-10T03:00:00Z → 2026年10月10日（日本時間。サーバーとブラウザで同じ表示になる） */
export function formatDate(iso: string | null | undefined): string {
  return iso ? jaDate.format(new Date(iso)) : ''
}

/** 2026-10-10T03:00:00Z → 2026/10/10 12:00（日本時間） */
export function formatDateTime(iso: string | null | undefined): string {
  return iso ? jaDateTime.format(new Date(iso)) : ''
}

/**
 * <input type="datetime-local"> 用の値にする（日本時間の 2026-10-10T12:00）。
 * ブラウザの時計がどの国の設定でも、日本時間で編集できるようにする。
 */
export function toDatetimeLocal(iso: string | null | undefined): string {
  if (!iso) return ''
  const parts = Object.fromEntries(
    new Intl.DateTimeFormat('sv-SE', {
      timeZone: TOKYO,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      hourCycle: 'h23',
    })
      .formatToParts(new Date(iso))
      .map((p) => [p.type, p.value]),
  )
  return `${parts.year}-${parts.month}-${parts.day}T${parts.hour}:${parts.minute}`
}
