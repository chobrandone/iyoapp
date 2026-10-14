// https://docs.expo.dev/guides/using-eslint/
const { defineConfig } = require('eslint/config');
const expoConfig = require('eslint-config-expo/flat');
const prettierRecommended = require('eslint-plugin-prettier/recommended');

module.exports = defineConfig([
  expoConfig,
  prettierRecommended,
  {
    ignores: [
      '**/node_modules/**',
      '**/.expo/**',
      '**/dist/**',
      'apps/*/ios/**',
      'apps/*/android/**',
      'supabase/functions/**',
      '**/expo-env.d.ts',
    ],
  },
  {
    settings: {
      // Resolve each app's `@/*` alias against its own tsconfig.
      'import/resolver': {
        typescript: {
          project: ['apps/*/tsconfig.json', 'packages/*/tsconfig.json'],
        },
      },
    },
    rules: {
      // Apps must never import from each other; shared code only via packages/.
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: [
                '**/apps/rider/**',
                '**/apps/driver/**',
                '@iyodriver/rider',
                '@iyodriver/driver',
              ],
              message: 'Apps cannot import from each other. Move shared code into packages/.',
            },
          ],
        },
      ],
    },
  },
  {
    files: ['**/*.ts', '**/*.tsx'],
    rules: {
      // The lucide barrel pulls ~3 800 icon modules into the bundle; import icons one by one.
      '@typescript-eslint/no-restricted-imports': [
        'error',
        {
          paths: [
            {
              name: 'lucide-react-native',
              message:
                "Import icons individually: import House from 'lucide-react-native/icons/house'.",
              allowTypeImports: true,
            },
          ],
        },
      ],
    },
  },
]);
