<script setup lang="ts">
definePageMeta({ middleware: 'admin' })
useSeoMeta({ title: '記事の編集', robots: 'noindex' })

const route = useRoute()
const { data: article, error } = await useFetch<AdminArticle>(
  () => `/api/admin/articles/${route.params.id}`,
)
</script>

<template>
  <div>
    <h1>記事の編集</h1>
    <p v-if="error" role="alert" class="error">
      記事を読み込めませんでした（削除されたか、ログインが切れた可能性があります）。
      <NuxtLink to="/admin">一覧に戻る</NuxtLink>
    </p>
    <ArticleEditor
      v-else-if="article"
      :key="article.id"
      :initial="article"
      submit-label="保存する"
    />
  </div>
</template>
