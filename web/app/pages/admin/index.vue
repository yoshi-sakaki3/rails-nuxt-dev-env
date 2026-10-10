<script setup lang="ts">
// 管理画面：記事の一覧（下書き・予約中も含む）と削除
definePageMeta({ middleware: 'admin' })
useSeoMeta({ title: '記事の管理', robots: 'noindex' })

const route = useRoute()
const { data, error, refresh } = await useFetch<{ articles: AdminArticle[] }>('/api/admin/articles')

const notice = ref(typeof route.query.notice === 'string' ? route.query.notice : '')
const actionError = ref('')
/** 削除の確認を出している記事の ID（1件ずつ確認する） */
const confirmingId = ref<number | null>(null)
const deletingId = ref<number | null>(null)

async function remove(article: AdminArticle) {
  deletingId.value = article.id
  actionError.value = ''
  try {
    await $fetch(`/api/admin/articles/${article.id}`, { method: 'DELETE' })
    notice.value = `「${article.title}」を削除しました。`
    await refresh()
  } catch (e) {
    actionError.value = `削除できませんでした：${readApiError(e).message}`
  } finally {
    deletingId.value = null
    confirmingId.value = null
  }
}

async function logout() {
  await $fetch('/api/admin/logout', { method: 'POST' })
  await navigateTo('/admin/login')
}
</script>

<template>
  <div>
    <div class="page-head">
      <h1>記事の管理</h1>
      <div class="actions">
        <NuxtLink to="/admin/new" class="btn btn-primary">新しい記事</NuxtLink>
        <button type="button" class="btn" @click="logout">ログアウト</button>
      </div>
    </div>

    <p v-if="notice" role="status" class="notice">{{ notice }}</p>
    <p v-if="error || actionError" role="alert" class="error">
      {{ actionError || '記事を読み込めませんでした。' }}
    </p>

    <p v-if="data && data.articles.length === 0" class="empty">記事はまだありません。</p>
    <ul v-else-if="data" class="admin-list">
      <li v-for="a in data.articles" :key="a.id" :data-testid="`article-${a.id}`">
        <div class="who">
          <span class="badge" :class="{ live: a.visible, scheduled: a.scheduled }">{{
            statusLabel(a)
          }}</span>
          <NuxtLink :to="`/admin/${a.id}`" class="title">{{ a.title }}</NuxtLink>
          <div class="mute">
            <span>/articles/{{ a.slug }}</span>
            <span v-if="a.publishedAt">公開日時：{{ formatDateTime(a.publishedAt) }}</span>
          </div>
        </div>
        <div class="actions">
          <NuxtLink v-if="a.visible" :to="`/articles/${a.slug}`" class="btn">公開ページ</NuxtLink>
          <template v-if="confirmingId === a.id">
            <span class="confirm-text">削除しますか？</span>
            <button
              type="button"
              class="btn btn-danger"
              :disabled="deletingId === a.id"
              @click="remove(a)"
            >
              {{ deletingId === a.id ? '削除中…' : 'はい、削除する' }}
            </button>
            <button type="button" class="btn" @click="confirmingId = null">やめる</button>
          </template>
          <button v-else type="button" class="btn" @click="confirmingId = a.id">削除</button>
        </div>
      </li>
    </ul>
  </div>
</template>
