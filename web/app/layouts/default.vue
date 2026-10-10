<script setup lang="ts">
const { siteName } = useRuntimeConfig().public
const year = new Date().getFullYear()
</script>

<template>
  <div class="site">
    <header class="site-header">
      <nav>
        <NuxtLink to="/" class="brand">{{ siteName }}</NuxtLink>
        <NuxtLink to="/">お知らせ一覧</NuxtLink>
        <NuxtLink to="/admin" class="admin-link">管理画面</NuxtLink>
      </nav>
    </header>
    <main>
      <slot />
    </main>
    <footer class="site-footer">© {{ year }} {{ siteName }}（内容はすべて架空です）</footer>
  </div>
</template>
