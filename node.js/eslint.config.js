module.exports = [
  {
    ...require("@eslint/js").configs.recommended,
    files: ["src/**/*.js"],
    languageOptions: {
      globals: {
        console: "readonly",
      },
      sourceType: "commonjs",
      ecmaVersion: "latest",
    },
  },
];
