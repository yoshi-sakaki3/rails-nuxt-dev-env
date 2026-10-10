// @ts-check
// 設定の中身は @nuxt/eslint が作る（Nuxt と Vue・TypeScript 向けのルール）
import withNuxt from './.nuxt/eslint.config.mjs'

export default withNuxt({
  rules: {
    // <input /> の書き方は Prettier に任せる（ESLint と好みがぶつかるため）
    'vue/html-self-closing': 'off',
  },
})
