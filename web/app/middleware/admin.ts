// 管理画面の入口の見張り。ログインしていなければ、ログイン画面へ送る。
// 注意：これは画面の出し分けだけ。データを守っているのは、サーバー側（Nuxt のサーバーと Rails）の確認。
export default defineNuxtRouteMiddleware(async () => {
  const { loggedIn } = await $fetch<{ loggedIn: boolean }>('/api/admin/me').catch(() => ({
    loggedIn: false,
  }))
  if (!loggedIn) return navigateTo('/admin/login')
})
