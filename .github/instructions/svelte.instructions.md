---
description: "Use when writing or editing Svelte components. Enforces Svelte 5 runes syntax, reactive state, effects, transitions, and component prop conventions."
applyTo: "**/*.svelte"
---

# Svelte 5 Component Rules

## Runes — always use Svelte 5, not Svelte 4 syntax

- Local state: `let count = $state(0)` — never plain `let count = 0` for reactive values
- Derived values: `let ppu = $derived(price / vol)` — never `$: ppu = price / vol`
- Side effects: `$effect(() => { ... })` — never `$: { sideEffect() }`
- Props: `let { foo, bar = 'default' } = $props()` — never `export let foo`
- Bindable props: add `$bindable()` as the default: `let { value = $bindable() } = $props()`
- App entry: `mount(App, { target })` from `'svelte'` — never `new App({ target })`

## Event Handlers — inline attributes, not directives

- `onclick={handler}` — never `on:click={handler}`
- `onfocus`, `onkeypress`, `ondblclick`, `oncontextmenu` — same pattern
- Event modifiers don't exist in Svelte 5; inline the logic:
  ```svelte
  <!-- ✓ -->
  onclick={(e) => { e.preventDefault(); handler() }}
  oncontextmenu={(e) => e.preventDefault()}

  <!-- ✗ -->
  on:click|preventDefault={handler}
  ```

## Props

- Declare all props via `$props()` destructuring
- Required props have no default; optional props get a default value
- JSDoc-annotate prop types inline: `let { /** @type {Product} */ product = $bindable() } = $props()`

## Each-block Binds

In runes mode, binding to an each-block iteration variable is forbidden. Use index access:
```svelte
<!-- ✓ -->
{#each items as item, i (item.id)}
  <Child bind:value={items[i]} />
{/each}

<!-- ✗ -->
{#each items as item (item.id)}
  <Child bind:value={item} />
{/each}
```

## Icons

- Import per-icon: `import Check from 'lucide-svelte/icons/check'`
- Never import from the barrel: `import { Check } from 'lucide-svelte'` ← **wrong**

## Reactivity

- Mutate arrays/objects by reassignment to trigger reactivity:
  ```js
  // ✓
  items = [...items, newItem]
  // ✗ (won't trigger updates outside $state deep proxy context)
  items.push(newItem)
  ```
- To sync a derived value back to a bindable parent prop, use `$effect`:
  ```js
  let ppu = $derived(price / vol)
  $effect(() => { product.ppu = ppu })
  ```

## Actions

- Type custom actions: `/** @type {import('svelte/action').Action} */ const myAction = (node) => { … }`

## Styling

- Tailwind utility classes only — no `<style>` blocks unless a utility doesn't exist
- Dynamic classes via template literal: `` class={`base ${condition ? 'variant' : ''}`} ``
- Self-closing non-void HTML elements are forbidden: use `<div></div>` not `<div />`
- `ring-lime-200` marks the winning (lowest PPU) comparator card
