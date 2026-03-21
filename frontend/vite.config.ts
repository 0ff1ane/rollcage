import { loadEnv, defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";
import { svelte } from '@sveltejs/vite-plugin-svelte'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");

  return {
    publicDir: false,
    plugins: [tailwindcss(), svelte()],
    build: {
      outDir: "../priv/static",
      target: ["es2022"],
      rollupOptions: {
        input: "src/main.ts",
        output: {
          assetFileNames: "assets/[name][extname]",
          chunkFileNames: "[name].js",
          entryFileNames: "assets/[name].js",
        },
      },
      commonjsOptions: {
        exclude: [],
        // include: []
      },
    },
    define: {
      __APP_ENV__: env.APP_ENV,
    },
  };
});
