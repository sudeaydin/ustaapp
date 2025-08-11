import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/setupTests.js'],
    css: true,
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/setupTests.js',
        '**/*.test.{js,jsx}',
        '**/*.spec.{js,jsx}',
        'src/utils/test-utils.jsx'
      ]
    }
  },
  resolve: {
    alias: {
      '@': '/src'
    }
  }
})