// ESLint configuration for the FinovaBank Expo app.
// The package.json "lint" script (eslint .) previously failed because no
// config file existed, even though eslint-config-expo was a dependency.
module.exports = {
  root: true,
  extends: ["expo"],
  ignorePatterns: ["node_modules/", "dist/", ".expo/", "babel.config.js"],
};
