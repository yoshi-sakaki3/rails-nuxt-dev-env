import { describe, expect, it } from 'vitest'
import { formatDate, formatDateTime, toDatetimeLocal } from '../app/utils/date'

describe('日付の表示', () => {
  it('世界標準時の日時を、日本時間の日付で表示する（日付をまたぐ場合も）', () => {
    expect(formatDate('2026-10-09T15:30:00Z')).toBe('2026年10月10日')
    expect(formatDate('2026-10-09T14:59:00Z')).toBe('2026年10月9日')
  })

  it('日時は 24 時間表記で表示する', () => {
    expect(formatDateTime('2026-10-10T03:05:00Z')).toBe('2026/10/10 12:05')
    expect(formatDateTime('2026-10-09T15:00:00Z')).toBe('2026/10/10 00:00')
  })

  it('空のときは空文字を返す', () => {
    expect(formatDate(null)).toBe('')
    expect(formatDateTime(undefined)).toBe('')
    expect(toDatetimeLocal(null)).toBe('')
  })

  it('入力欄（datetime-local）用に、日本時間の値を作る', () => {
    expect(toDatetimeLocal('2026-10-20T00:00:00Z')).toBe('2026-10-20T09:00')
    expect(toDatetimeLocal('2026-12-31T15:30:00.000Z')).toBe('2027-01-01T00:30')
  })
})
