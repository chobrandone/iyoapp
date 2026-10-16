import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react';
import { existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { loadEnv } from 'vite';
import { defineConfig } from 'vitest/config';

/**
 * One Supabase project connects all three apps. The rider and driver apps read
 * flutter/config/dev.json (--dart-define-from-file); the dashboard reads the same file unless
 * apps/admin/.env.local sets VITE_SUPABASE_URL / VITE_SUPABASE_ANON_KEY.
 */
function sharedSupabase(mode: string) {
  const env = loadEnv(mode, process.cwd(), 'VITE_');
  if (env.VITE_SUPABASE_URL && env.VITE_SUPABASE_ANON_KEY) return {};
  const file = fileURLToPath(
    new URL(`../../flutter/config/${mode === 'production' ? 'prod' : 'dev'}.json`, import.meta.url),
  );
  if (!existsSync(file)) return {};
  const config = JSON.parse(readFileSync(file, 'utf8')) as Record<string, string | undefined>;
  if (!config.SUPABASE_URL || !config.SUPABASE_PUBLISHABLE_KEY) return {};
  return {
    'import.meta.env.VITE_SUPABASE_URL': JSON.stringify(config.SUPABASE_URL),
    'import.meta.env.VITE_SUPABASE_ANON_KEY': JSON.stringify(config.SUPABASE_PUBLISHABLE_KEY),
  };
}

export default defineConfig(({ mode }) => ({
  plugins: [react(), tailwindcss()],
  resolve: { alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) } },
  define: mode === 'test' ? {} : sharedSupabase(mode),
  server: { port: 8084 },
  build: { chunkSizeWarningLimit: 1200 },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test-setup.ts'],
    css: false,
    // The first render of each lazy screen compiles it.
    testTimeout: 20_000,
  },
}));
