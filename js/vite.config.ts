import { defineConfig } from "vite";
import plugin from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [plugin()],
  server: {
    port: 64092,
  },
  build: {
    rollupOptions: {
      output: {
        // For the main JavaScript entry file
        entryFileNames: "client.js",

        // For static assets like CSS
        assetFileNames: () => {
          // if (assetInfo.name === 'style.css') { // Target a specific asset name
          // return 'css/custom-styles.css';
          // }
          return "client.[ext]"; // Default for other assets
        },

        // For code-split chunks
        chunkFileNames: "chunks/[name]-chunk.js",
      },
    },
  },
});
