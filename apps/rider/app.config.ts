import type { ConfigContext, ExpoConfig } from 'expo/config';

// Brand values are duplicated here (not imported from @iyodriver/ui) because app config
// is evaluated in Node, outside the Metro bundle.
const SPLASH_BACKGROUND = '#F6C200';

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: 'iyodriver',
  slug: 'iyodriver-rider',
  scheme: 'iyodriver',
  version: '0.1.0',
  orientation: 'portrait',
  icon: './assets/icon.png',
  userInterfaceStyle: 'light',
  ios: {
    bundleIdentifier: 'com.iyodriver.rider',
    supportsTablet: false,
    config: {
      googleMapsApiKey: process.env.EXPO_PUBLIC_GOOGLE_MAPS_API_KEY,
    },
    infoPlist: {
      NSLocationWhenInUseUsageDescription:
        'iyodriver uses your location to set your pickup point and show nearby drivers.',
    },
  },
  android: {
    package: 'com.iyodriver.rider',
    adaptiveIcon: {
      backgroundColor: SPLASH_BACKGROUND,
      foregroundImage: './assets/android-icon-foreground.png',
      backgroundImage: './assets/android-icon-background.png',
      monochromeImage: './assets/android-icon-monochrome.png',
    },
    config: {
      googleMaps: { apiKey: process.env.EXPO_PUBLIC_GOOGLE_MAPS_API_KEY },
    },
    permissions: ['ACCESS_COARSE_LOCATION', 'ACCESS_FINE_LOCATION'],
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
    appRole: 'rider',
    // eas: { projectId: '' }, // set by `npx eas-cli@latest init` inside apps/rider
  },
});
