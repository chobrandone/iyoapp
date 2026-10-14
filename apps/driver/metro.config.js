// Expo SDK 52+ configures Metro for monorepos automatically (watchFolders and
// nodeModulesPaths are derived from the workspace root), so no manual overrides are needed.
// https://docs.expo.dev/guides/monorepos/
const { getDefaultConfig } = require('expo/metro-config');

module.exports = getDefaultConfig(__dirname);
