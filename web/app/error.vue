<script setup lang="ts">
import type { NuxtError } from '#app'

const props = defineProps<{ error: NuxtError }>()
const notFound = computed(() => props.error.statusCode === 404)

useSeoMeta({
  title: () => (notFound.value ? 'ページが見つかりません' : 'エラーが発生しました'),
  robots: 'noindex',
})
</script>

<template>
  <NuxtLayout>
    <div class="empty">
      <h1>{{ notFound ? 'ページが見つかりません' : 'エラーが発生しました' }}</h1>
      <p class="mute">
        {{
          notFound
            ? 'お知らせが削除されたか、URL が間違っている可能性があります。'
            : '時間をおいて、もう一度お試しください。'
        }}
      </p>
      <button type="button" class="btn" @click="clearError({ redirect: '/' })">
        お知らせ一覧に戻る
      </button>
    </div>
  </NuxtLayout>
</template>
