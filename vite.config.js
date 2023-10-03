import { defineConfig } from "vite";
import { VitePWA } from "vite-plugin-pwa";
import { svelte } from "@sveltejs/vite-plugin-svelte";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    svelte(),
    VitePWA({
      includeAssets: [
        "favicon.ico",
        "apple-touch-icon-180x180.png",
        "maskable-icon-512x512.png",
        "robots.txt",
      ],
      manifest: {
        name: "Kum Sud - คุ้มสุด",
        short_name: "คุ้มสุด",
        description: "หาราคาต่อหน่วยที่ถูกที่สุด",
        theme_color: "#ffffff",
        icons: [
          {
            src: "pwa-192x192.png",
            sizes: "192x192",
            type: "image/png",
          },
          {
            src: "pwa-512x512.png",
            sizes: "512x512",
            type: "image/png",
          },
        ],
      },
    }),
  ],
});
