import type { ConfigContext, ExpoConfig } from 'expo/config';

// Brand values are duplicated here (not imported from @iyodriver/ui) because app config
// is evaluated in Node, outside the Metro bundle.
const SPLASH_BACKGROUND = '#F6C200';

// Google restricts a key to either iOS or Android apps, so separate keys per platform are
// supported; both fall back to EXPO_PUBLIC_GOOGLE_MAPS_API_KEY.
const MAPS_KEY = process.env.EXPO_PUBLIC_GOOGLE_MAPS_API_KEY;
const MAPS_KEY_IOS = process.env.EXPO_PUBLIC_GOOGLE_MAPS_IOS_API_KEY ?? MAPS_KEY;
const MAPS_KEY_ANDROID = process.env.EXPO_PUBLIC_GOOGLE_MAPS_ANDROID_API_KEY ?? MAPS_KEY;

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
      'react-native-maps',
      { iosGoogleMapsApiKey: MAPS_KEY_IOS, androidGoogleMapsApiKey: MAPS_KEY_ANDROID },
    ],
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
