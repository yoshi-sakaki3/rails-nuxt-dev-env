<script setup lang="ts">
definePageMeta({ middleware: 'admin' })
useSeoMeta({ title: '新しい記事', robots: 'noindex' })
</script>

<template>
  <div>
    <h1>新しい記事</h1>
    <ArticleEditor submit-label="保存する" />
  </div>
</template>
