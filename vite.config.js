import { defineConfig, loadEnv } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  // console.log({ env });
  return {
    define: {
      __APP_VERSION__: JSON.stringify(env.npm_package_version),
    },
    plugins: [svelte()],
  }
})
