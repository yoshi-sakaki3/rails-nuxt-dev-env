import { defineConfig } from 'vitest/config'

// 画面を立ち上げずに確かめられる部分（日付や表示名の計算）のテスト
export default defineConfig({
  test: {
    environment: 'node',
    include: ['tests/**/*.test.ts'],
  },
})
