<script setup lang="ts">
// お知らせの詳細（公開ページ）。タイトルと説明文を、検索結果や SNS のシェア用に設定する
const route = useRoute()
const { siteName } = useRuntimeConfig().public

const { data: article, error } = await useFetch<ArticleDetail>(
  () => `/api/articles/${route.params.slug}`,
)

if (error.value || !article.value) {
  // 下書き・予約中・存在しない記事は、どれも「見つかりません」にする（下書きがあることも知らせない）
  throw createError({
    statusCode: error.value?.statusCode === 404 || !error.value ? 404 : 500,
    // statusMessage は HTTP の 1 行目に入るので、英数字だけにする（日本語の表示は error.vue が担当）
    statusMessage: 'Not Found',
    fatal: true,
  })
}

useSeoMeta({
  title: () => `${article.value?.title} | ${siteName}`,
  description: () => (article.value ? metaDescription(article.value) : ''),
  ogTitle: () => article.value?.title,
  ogDescription: () => (article.value ? metaDescription(article.value) : ''),
  ogType: 'article',
  articlePublishedTime: () => article.value?.publishedAt ?? undefined,
  articleModifiedTime: () => article.value?.updatedAt,
})
</script>

<template>
  <article v-if="article" class="article">
    <p class="mute">
      <time :datetime="article.publishedAt ?? undefined">{{
        formatDate(article.publishedAt)
      }}</time>
    </p>
    <h1>{{ article.title }}</h1>
    <!-- 本文は文字として表示する（HTML として解釈しないので、タグが入っていても実行されない） -->
    <div class="article-body">{{ article.body }}</div>
    <p class="back"><NuxtLink to="/" class="btn">← お知らせ一覧に戻る</NuxtLink></p>
  </article>
</template>
