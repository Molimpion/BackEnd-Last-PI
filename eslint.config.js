import js from "@eslint/js";
import tseslint from "typescript-eslint";

const semExpress = {
  name: "express",
  message: "Regra de negocio nao conhece HTTP. Mova para o controller.",
};

const semPrisma = {
  group: ["@prisma/client", "**/infra/db.js", "**/generated/prisma/**"],
  message: "Somente o repository conhece Prisma.",
};

export default tseslint.config(
  {
    ignores: ["dist/**", "coverage/**", "node_modules/**", "src/generated/**"],
  },
  js.configs.recommended,
  tseslint.configs.recommendedTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService: {
          allowDefaultProject: ["*.js"],
        },
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      "@typescript-eslint/no-explicit-any": "error",
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
      "@typescript-eslint/consistent-type-imports": "error",
    },
  },
  {
    files: [
      "src/features/*/service.ts",
      "src/features/*/usecases/**/*.ts",
      "src/features/*/enums.ts",
    ],
    rules: {
      "no-restricted-imports": ["error", { paths: [semExpress], patterns: [semPrisma] }],
    },
  },
  {
    files: ["src/features/*/controller.ts"],
    rules: {
      "no-restricted-imports": ["error", { patterns: [semPrisma] }],
    },
  },
  {
    files: ["src/features/*/repository.ts"],
    rules: {
      "no-restricted-imports": ["error", { paths: [semExpress] }],
    },
  },
  {
    files: ["tests/**/*.ts", "**/*.test.ts"],
    rules: {
      "@typescript-eslint/no-unsafe-assignment": "off",
      "@typescript-eslint/no-unsafe-member-access": "off",
    },
  },
);
