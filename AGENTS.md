# kumsud — Agent Instructions

**KUM SUD (คุ้มสุด)** is a single-page Svelte 5 + Vite app that calculates price-per-unit (PPU) across multiple products so users can find the best value. The UI is in Thai.

## Commands

```bash
pnpm dev          # start dev server (http://localhost:5173)
pnpm build        # production build → dist/
pnpm preview      # preview production build
pnpm lint         # ESLint check
pnpm lint:fix     # ESLint auto-fix
pnpm release      # bump version + changelog (commit-and-tag-version)
```

## Architecture

- **No router** — this is a plain Vite + Svelte app, not SvelteKit.
- `src/App.svelte` — root component; owns the `comparators` array and computes `maxPPU`.
- `src/components/Comparator.svelte` — card for one product; receives `product` (bind), `handleRemove`, and `isMinPPU`.
- `src/components/Counter.svelte` — reusable quantity counter.

## Key Conventions

- **Icons**: import individually from `lucide-svelte/icons/<name>`, not from the barrel `lucide-svelte`.
- **Types**: JSDoc annotations (`/** @type {…} */`) — no TypeScript files.
- **Svelte 5 runes**: use `$state()`, `$derived()`, `$effect()`, `$props()`, `$bindable()`; event handlers are inline attributes (`onclick`, `onfocus`, etc.).
- **Styling**: Tailwind CSS utility classes only; `@tailwindcss/forms` plugin is active.
- **Responsive grid**: `col-span-12` (mobile), `lg:col-span-6` (desktop) inside a `grid-cols-12` parent.
- **PPU formula**: `ppu = price / (vol * quantity)` — the lowest value wins (highlighted with `ring-lime-200`).
- **Each-block binds**: use index access `bind:prop={array[i]}` — Svelte 5 runes mode disallows binding to the iteration variable directly.

## Tooling

- Package manager: **pnpm**
- Linter: `@antfu/eslint-config` + `eslint-plugin-svelte` + `eslint-plugin-format` (see `eslint.config.js`)
- Formatter: Prettier (see `prettier.config.mjs`)
- PostCSS + Autoprefixer configured in `postcss.config.js`
