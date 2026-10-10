import { describe, expect, it } from 'vitest'
import { metaDescription, readApiError, statusLabel } from '../app/utils/articles'

describe('記事の表示用の計算', () => {
  it('状態の表示名を出し分ける', () => {
    expect(statusLabel({ status: 'draft', visible: false, scheduled: false })).toBe('下書き')
    expect(statusLabel({ status: 'published', visible: false, scheduled: true })).toBe('予約公開')
    expect(statusLabel({ status: 'published', visible: true, scheduled: false })).toBe('公開中')
  })

  it('説明文は要約を使い、なければ本文の先頭から作る（改行はまとめる）', () => {
    expect(metaDescription({ summary: '要約です', body: '本文' })).toBe('要約です')
    expect(metaDescription({ summary: null, body: '1行目\n\n2行目' })).toBe('1行目 2行目')
  })

  it('説明文が長いときは、決めた長さで切って … を付ける', () => {
    const result = metaDescription({ summary: null, body: 'あ'.repeat(200) }, 50)
    expect(result).toHaveLength(50)
    expect(result.endsWith('…')).toBe(true)
  })

  it('API のエラーから、項目ごとの誤りを取り出す', () => {
    const e = { statusCode: 422, data: { errors: { title: 'タイトルを入力してください' } } }
    expect(readApiError(e)).toEqual({
      status: 422,
      message: '入力内容を確認してください',
      errors: { title: 'タイトルを入力してください' },
    })
  })

  it('Nuxt のサーバーが返したエラーは、印の true ではなく、中の文面を読む', () => {
    const e = { statusCode: 401, data: { error: true, data: { error: '合言葉が違います' } } }
    expect(readApiError(e).message).toBe('合言葉が違います')
  })

  it('Rails が返したエラー（error が文面そのもの）も読める', () => {
    const e = { statusCode: 404, data: { error: '見つかりません' } }
    expect(readApiError(e).message).toBe('見つかりません')
  })

  it('つながらないときも、落ちずにメッセージを返す', () => {
    expect(readApiError(new Error('fetch failed')).message).toBe(
      '通信に失敗しました（接続できません）',
    )
  })
})
