import type { ConfigContext, ExpoConfig } from 'expo/config';

// Brand values are duplicated here (not imported from @iyodriver/ui) because app config
// is evaluated in Node, outside the Metro bundle.
const SPLASH_BACKGROUND = '#F6C200';

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: 'iyodriver Driver',
  slug: 'iyodriver-driver',
  scheme: 'iyodriver-driver',
  version: '0.1.0',
  orientation: 'portrait',
  icon: './assets/icon.png',
  userInterfaceStyle: 'light',
  ios: {
    bundleIdentifier: 'com.iyodriver.driver',
    supportsTablet: false,
    config: {
      googleMapsApiKey: process.env.EXPO_PUBLIC_GOOGLE_MAPS_API_KEY,
    },
    // Background location + permission strings are wired up with expo-location in Phase 7.
  },
  android: {
    package: 'com.iyodriver.driver',
    adaptiveIcon: {
      backgroundColor: SPLASH_BACKGROUND,
      foregroundImage: './assets/android-icon-foreground.png',
      backgroundImage: './assets/android-icon-background.png',
      monochromeImage: './assets/android-icon-monochrome.png',
    },
    config: {
      googleMaps: { apiKey: process.env.EXPO_PUBLIC_GOOGLE_MAPS_API_KEY },
    },
    predictiveBackGestureEnabled: false,
  },
  web: {
    favicon: './assets/favicon.png',
  },
  plugins: [
    'expo-router',
    'expo-font',
    'expo-localization',
    [
      'expo-splash-screen',
      {
        image: './assets/splash-icon.png',
        imageWidth: 200,
        resizeMode: 'contain',
        backgroundColor: SPLASH_BACKGROUND,
      },
    ],
  ],
  experiments: {
    typedRoutes: true,
  },
  extra: {
    appRole: 'driver',
    // eas: { projectId: '' }, // set by `npx eas-cli@latest init` inside apps/driver
  },
});
