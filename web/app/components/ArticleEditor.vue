<script setup lang="ts">
// 記事の入力フォーム（新規と編集で共通）。誤りは各欄の下に出し、入力した値は消さない
const props = defineProps<{
  initial?: AdminArticle
  submitLabel: string
}>()

const form = reactive<ArticleForm>({
  title: props.initial?.title ?? '',
  slug: props.initial?.slug ?? '',
  summary: props.initial?.summary ?? '',
  body: props.initial?.body ?? '',
  status: props.initial?.status ?? 'draft',
  publishedAt: toDatetimeLocal(props.initial?.publishedAt),
})

const errors = ref<ArticleErrors>({})
const formError = ref('')
const saving = ref(false)

async function submit() {
  saving.value = true
  errors.value = {}
  formError.value = ''
  try {
    const saved = await $fetch<AdminArticle>(
      props.initial ? `/api/admin/articles/${props.initial.id}` : '/api/admin/articles',
      {
        method: props.initial ? 'PATCH' : 'POST',
        // 公開日時が空なら null を送る（公開するときは「今すぐ」になる）
        body: { article: { ...form, publishedAt: form.publishedAt || null } },
      },
    )
    await navigateTo({ path: '/admin', query: { notice: `「${saved.title}」を保存しました。` } })
  } catch (e) {
    const result = readApiError(e)
    if (result.status === 401) return navigateTo('/admin/login')
    errors.value = result.errors
    formError.value = result.message
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <form class="card form" novalidate @submit.prevent="submit">
    <p v-if="formError" role="alert" class="error">{{ formError }}</p>

    <div class="field">
      <label for="title">タイトル <span class="req">必須</span></label>
      <input id="title" v-model="form.title" maxlength="100" required />
      <p v-if="errors.title" class="error">{{ errors.title }}</p>
    </div>

    <div class="field">
      <label for="slug">URL 用の名前 <span class="req">必須</span></label>
      <input id="slug" v-model="form.slug" maxlength="80" placeholder="autumn-campaign" required />
      <p v-if="errors.slug" class="error">{{ errors.slug }}</p>
      <p v-else class="mute">
        公開ページの URL は /articles/{{ form.slug || '（ここに入る）' }} になります。
      </p>
    </div>

    <div class="field">
      <label for="summary">要約</label>
      <input id="summary" v-model="form.summary" maxlength="200" />
      <p v-if="errors.summary" class="error">{{ errors.summary }}</p>
      <p v-else class="mute">一覧と、検索結果の説明文に使います（200文字まで）。</p>
    </div>

    <div class="field">
      <label for="body">本文 <span class="req">必須</span></label>
      <textarea id="body" v-model="form.body" rows="10" required></textarea>
      <p v-if="errors.body" class="error">{{ errors.body }}</p>
    </div>

    <div class="field-row">
      <div class="field">
        <label for="status">状態</label>
        <select id="status" v-model="form.status">
          <option value="draft">下書き</option>
          <option value="published">公開</option>
        </select>
        <p v-if="errors.status" class="error">{{ errors.status }}</p>
      </div>
      <div class="field">
        <label for="publishedAt">公開日時（日本時間）</label>
        <input id="publishedAt" v-model="form.publishedAt" type="datetime-local" />
        <p v-if="errors.published_at" class="error">{{ errors.published_at }}</p>
        <p v-else class="mute">
          空のまま公開すると、今すぐ公開します。未来の日時にすると予約公開になります。
        </p>
      </div>
    </div>

    <div class="actions">
      <button type="submit" class="btn btn-primary" :disabled="saving">
        {{ saving ? '保存中…' : submitLabel }}
      </button>
      <NuxtLink to="/admin" class="btn">一覧に戻る</NuxtLink>
    </div>
  </form>
</template>
