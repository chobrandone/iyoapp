import { getLocales } from 'expo-localization';
import { createInstance, type i18n as I18n, type Resource } from 'i18next';
import { initReactI18next } from 'react-i18next';

import type { Language } from '../schemas/common';
import { commonEn, commonFr } from './common';

export { commonEn, commonFr, type CommonStrings } from './common';

export const SUPPORTED_LANGUAGES: readonly Language[] = ['en', 'fr'];
/** Douala and Yaoundé are majority francophone, so French is the fallback for other device languages. */
export const FALLBACK_LANGUAGE: Language = 'fr';

export function detectDeviceLanguage(): Language {
  for (const locale of getLocales()) {
    const code = locale.languageCode;
    if (code === 'en' || code === 'fr') return code;
  }
  return FALLBACK_LANGUAGE;
}

export type AppTranslations = { en: Record<string, unknown>; fr: Record<string, unknown> };

/**
 * Initialises i18next with the shared `common` namespace plus the calling app's `app`
 * namespace. Call once, before rendering, from each app's root layout module.
 */
/** The single i18next instance used by the running app. */
export const i18n: I18n = createInstance();

export function initI18n(appStrings: AppTranslations, language?: Language): I18n {
  if (i18n.isInitialized) return i18n;

  const resources: Resource = {
    en: { common: commonEn, app: appStrings.en },
    fr: { common: commonFr, app: appStrings.fr },
  };

  void i18n.use(initReactI18next).init({
    resources,
    lng: language ?? detectDeviceLanguage(),
    fallbackLng: FALLBACK_LANGUAGE,
    supportedLngs: SUPPORTED_LANGUAGES as Language[],
    ns: ['app', 'common'],
    defaultNS: 'app',
    fallbackNS: 'common',
    interpolation: { escapeValue: false },
    returnNull: false,
    initAsync: false,
  });

  return i18n;
}

export { useTranslation, Trans } from 'react-i18next';
