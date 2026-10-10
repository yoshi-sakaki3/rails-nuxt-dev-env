<script setup lang="ts">
useSeoMeta({ title: '管理画面ログイン', robots: 'noindex' })

const token = ref('')
const error = ref('')
const sending = ref(false)

async function login() {
  sending.value = true
  error.value = ''
  try {
    await $fetch('/api/admin/login', { method: 'POST', body: { token: token.value } })
    await navigateTo('/admin')
  } catch (e) {
    error.value = readApiError(e).message
  } finally {
    sending.value = false
  }
}
</script>

<template>
  <div>
    <h1>管理画面ログイン</h1>
    <form class="card form narrow" @submit.prevent="login">
      <div class="field">
        <label for="token">合言葉</label>
        <input
          id="token"
          v-model="token"
          type="password"
          autocomplete="current-password"
          required
          autofocus
        />
        <p v-if="error" role="alert" class="error">{{ error }}</p>
      </div>
      <button type="submit" class="btn btn-primary" :disabled="sending">
        {{ sending ? '確認中…' : 'ログイン' }}
      </button>
      <p class="mute">
        見本の合言葉は、<code>.env</code> の <code>ADMIN_API_TOKEN</code>（ローカル開発専用）です。
      </p>
    </form>
  </div>
</template>
