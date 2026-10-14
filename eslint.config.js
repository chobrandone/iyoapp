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
]);
