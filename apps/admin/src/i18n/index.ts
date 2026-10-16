import i18next, { changeLanguage } from 'i18next';
import { initReactI18next } from 'react-i18next';

import en from './en.json';
import fr from './fr.json';

export type Lang = 'en' | 'fr';
const KEY = 'iyodriver.admin.lang';

/** The saved choice, else French only when the browser prefers French over English. */
function initialLanguage(): Lang {
  try {
    const saved = localStorage.getItem(KEY);
    if (saved === 'en' || saved === 'fr') return saved;
  } catch {
    // Storage blocked: fall through to the browser languages.
  }
  const prefs = typeof navigator === 'undefined' ? [] : navigator.languages;
  const first = prefs.find((l) => /^(en|fr)\b/i.test(l));
  return first?.toLowerCase().startsWith('fr') ? 'fr' : 'en';
}

export function setLanguage(lang: Lang) {
  try {
    localStorage.setItem(KEY, lang);
  } catch {
    // Not persisted; still switch for this session.
  }
  document.documentElement.lang = lang;
  void changeLanguage(lang);
}

export function initI18n(lang: Lang = initialLanguage()) {
  if (typeof document !== 'undefined') document.documentElement.lang = lang;
  // eslint-disable-next-line import/no-named-as-default-member -- the default instance is the app's
  void i18next.use(initReactI18next).init({
    resources: { en: { translation: en }, fr: { translation: fr } },
    lng: lang,
    fallbackLng: 'en',
    // React escapes text already.
    interpolation: { escapeValue: false },
    returnNull: false,
  });
  return i18next;
}
