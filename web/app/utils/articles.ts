/** 公開側の一覧に出る記事 */
export type ArticleSummary = {
  id: number
  title: string
  slug: string
  summary: string | null
  publishedAt: string | null
}

/** 公開側の詳細 */
export type ArticleDetail = ArticleSummary & { body: string; updatedAt: string }

/** 管理側で扱う記事（下書き・予約中も含む） */
export type AdminArticle = ArticleDetail & {
  status: 'draft' | 'published'
  /** 公開側に出ている */
  visible: boolean
  /** 公開済みだが、公開日時がまだ来ていない */
  scheduled: boolean
}

export type ArticleList = {
  articles: ArticleSummary[]
  page: number
  totalPages: number
  total: number
}

export type ArticleForm = {
  title: string
  slug: string
  summary: string
  body: string
  status: 'draft' | 'published'
  /** 日本時間の 2026-10-10T12:00（空なら「公開したとき」になる） */
  publishedAt: string
}

export type ArticleErrors = Partial<
  Record<'title' | 'slug' | 'summary' | 'body' | 'status' | 'published_at', string>
>

/** 管理側の一覧に出す状態の表示名 */
export function statusLabel(
  article: Pick<AdminArticle, 'status' | 'visible' | 'scheduled'>,
): string {
  if (article.status === 'draft') return '下書き'
  if (article.scheduled) return '予約公開'
  return article.visible ? '公開中' : '公開済み'
}

/** 検索エンジン向けの説明文。要約がなければ、本文の先頭から作る */
export function metaDescription(
  article: Pick<ArticleDetail, 'summary' | 'body'>,
  max = 120,
): string {
  const source = (article.summary ?? article.body).replace(/\s+/g, ' ').trim()
  return source.length > max ? `${source.slice(0, max - 1)}…` : source
}

/**
 * API のエラー（$fetch が投げたもの）から、項目ごとの誤りと全体のメッセージを取り出す。
 * 形が 2 通りある：
 *   Rails から          … { error: '文面' } または { errors: { 項目: '文面' } }
 *   Nuxt のサーバーから … { error: true, data: { error: '文面' } }（error は「エラーである」という印）
 */
export function readApiError(e: unknown): {
  message: string
  errors: ArticleErrors
  status: number
} {
  const err = e as {
    statusCode?: number
    data?: { error?: unknown; errors?: ArticleErrors; data?: { error?: unknown } }
  }
  const status = err?.statusCode ?? 0
  const errors = err?.data?.errors ?? {}
  const text = [err?.data?.data?.error, err?.data?.error].find(
    (v): v is string => typeof v === 'string' && v !== '',
  )
  const message =
    text ??
    (Object.keys(errors).length > 0
      ? '入力内容を確認してください'
      : `通信に失敗しました（${status || '接続できません'}）`)
  return { message, errors, status }
}
