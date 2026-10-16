import './index.css';

import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';

import { App } from './app';
import { DemoAdminBackend } from './data/demo';
import { makeQueryClient } from './data/queries';
import type { AdminRepository } from './data/repository';
import { SupabaseAdminBackend } from './data/supabase';
import { initI18n } from './i18n';

initI18n();

const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const key = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;

// Supabase when a project is configured (.env.local), the Douala demo dataset otherwise.
// In development, `?review` opens the demo already signed in (design screenshots).
const review = import.meta.env.DEV && new URLSearchParams(location.search).has('review');
const repo: AdminRepository =
  url && key
    ? new SupabaseAdminBackend(url, key)
    : new DemoAdminBackend({ persistSession: true, signedIn: review });

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App repo={repo} client={makeQueryClient()} />
  </StrictMode>,
);
