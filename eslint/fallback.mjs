// Default ESLint flat config used by Neovim when a project has no
// eslint.config.* of its own (see lua/emirtech/util/eslint.lua).
//
// It is deliberately conservative: @eslint/js recommended, plus
// typescript-eslint and eslint-plugin-vue recommended *only if* the project
// already has them installed. Nothing is required beyond eslint itself.
import { createRequire } from "node:module";
import path from "node:path";

export default function makeConfig(root, bundleDir) {
	const fromRoot = createRequire(path.join(root, "package.json"));
	const fromBundle = createRequire(path.join(bundleDir, "package.json"));

	// Resolution order: the project root, then relative to the project's own
	// eslint (non-hoisted layouts such as pnpm), then the bundle shipped with
	// the Neovim config.
	const load = (name) => {
		try {
			return fromRoot(name);
		} catch {}
		try {
			return createRequire(fromRoot.resolve("eslint/package.json"))(name);
		} catch {}
		try {
			return fromBundle(name);
		} catch {}
		return null;
	};

	const configs = [
		{
			ignores: [
				"**/node_modules/**",
				"**/dist/**",
				"**/build/**",
				"**/coverage/**",
				"**/.nuxt/**",
				"**/.output/**",
				"**/.next/**",
			],
		},
	];

	const js = load("@eslint/js");
	if (js) configs.push(js.configs.recommended);

	const globals = load("globals");
	configs.push({
		files: ["**/*.{js,mjs,cjs,jsx,ts,mts,cts,tsx,vue}"],
		languageOptions: {
			ecmaVersion: "latest",
			sourceType: "module",
			globals: { ...(globals?.browser ?? {}), ...(globals?.node ?? {}) },
		},
	});

	const ts = load("typescript-eslint");
	if (ts) configs.push(...ts.configs.recommended);

	const vue = load("eslint-plugin-vue");
	if (vue) {
		configs.push(...vue.configs["flat/recommended"]);
		if (ts) {
			configs.push({
				files: ["**/*.vue"],
				languageOptions: { parserOptions: { parser: ts.parser } },
			});
		}
	}

	return configs;
}
