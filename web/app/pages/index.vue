<script setup lang="ts">
// お知らせの一覧（公開ページ）。サーバー側で HTML を作るので、検索エンジンにも内容が読まれる
const route = useRoute()
const { siteName } = useRuntimeConfig().public

const page = computed(() => {
  const n = Number(route.query.page)
  return Number.isSafeInteger(n) && n >= 1 ? n : 1
})

const { data, error } = await useFetch<ArticleList>('/api/articles', {
  query: { page },
})

useSeoMeta({
  title: () => (page.value > 1 ? `お知らせ（${page.value}ページ目） | ${siteName}` : siteName),
  description: '最新のお知らせをお届けします。',
  ogTitle: siteName,
  ogType: 'website',
})
</script>

<template>
  <div>
    <h1>お知らせ</h1>

    <p v-if="error" role="alert" class="error">
      お知らせを読み込めませんでした。時間をおいて、もう一度お試しください。
    </p>

    <template v-else-if="data">
      <p v-if="data.articles.length === 0" class="empty">お知らせはまだありません。</p>
      <ul v-else class="article-list">
        <li v-for="a in data.articles" :key="a.id">
          <time :datetime="a.publishedAt ?? undefined">{{ formatDate(a.publishedAt) }}</time>
          <h2>
            <NuxtLink :to="`/articles/${a.slug}`">{{ a.title }}</NuxtLink>
          </h2>
          <p v-if="a.summary" class="mute">{{ a.summary }}</p>
        </li>
      </ul>

      <nav v-if="data.totalPages > 1" class="pager" aria-label="ページ送り">
        <NuxtLink
          v-if="page > 1"
          :to="{ query: page === 2 ? {} : { page: page - 1 } }"
          class="btn"
          rel="prev"
        >
          ← 新しいお知らせ
        </NuxtLink>
        <span class="mute">{{ page }} / {{ data.totalPages }} ページ</span>
        <NuxtLink
          v-if="page < data.totalPages"
          :to="{ query: { page: page + 1 } }"
          class="btn"
          rel="next"
        >
          前のお知らせ →
        </NuxtLink>
      </nav>
    </template>
  </div>
</template>
