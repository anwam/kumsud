<script>
  import { Minus } from "lucide-svelte";
  import { slide } from "svelte/transition";

  let price = 0;
  let vol = 1;
  let quantity = 1;
  export let product;
  export let handleRemove;
  export let isMinPPU;

  $: ppu = price / vol / quantity;
  $: product = { ...product, ppu };
</script>

<div
  transition:slide={{
    duration: 250,
    delay: 50,
    axis: "y",
  }}
  class={`snap-start scroll-my-2 transition-all duration-300 col-span-12 md:col-span-6 lg:col-span-4 bg-gray-50 shadow p-2 md:p-4 gap-2 lg:gap-4 flex flex-col rounded-lg ${
    isMinPPU(product.id) ? "ring-2 ring-lime-200  to-lime-50" : ""
  }`}
>
  <div class="flex flex-row justify-between">
    <p>
      {`# ${product.id}`}
      {#if isMinPPU(product.id)}
        <span>คุ้มกว่า</span>
      {/if}
    </p>
    <button
      tabindex="-1"
      class="p-2 text-red-600 transition-all duration-300 bg-red-100 rounded-full w-fit hover:ring-2 hover:ring-red-200"
      on:click|preventDefault={handleRemove(product.id)}
    >
      <Minus size={12} />
    </button>
  </div>
  <form class="grid grid-flow-row grid-cols-4 gap-2 text-sm">
    <div class="col-span-2 md:col-span-4">
      <label class="text-xs text-gray-600" for={`price-${product.id}`}
        >ราคา</label
      >
      <input
        class="w-full p-1 text-base border border-blue-200 rounded"
        on:focus={(e) => e.currentTarget.select()}
        pattern="\d*"
        type="number"
        name="price"
        id={`price-${product.id}`}
        bind:value={price}
      />
    </div>
    <div class="col-span-1 md:col-span-2">
      <label class="text-xs text-gray-600" for={`vol-${product.id}`}
        >ปริมาตร</label
      >
      <input
        class="w-full p-1 text-base border border-red-200 rounded text-end"
        on:focus={(e) => e.currentTarget.select()}
        pattern="\d*"
        type="number"
        name="vol"
        id={`vol-${product.id}`}
        bind:value={vol}
      />
    </div>
    <div class="col-span-1 md:col-span-2">
      <label class="text-xs text-gray-600" for={`quant-${product.id}`}
        >จำนวน</label
      >
      <input
        class="w-full p-1 text-base border rounded text-end border-lime-400"
        on:focus={(e) => e.currentTarget.select()}
        pattern="\d*"
        type="number"
        name="quant"
        id={`quant-${product.id}`}
        bind:value={quantity}
      />
    </div>
    <p class="col-span-4 text-lg" id={`ppu-${product.id}`}>
      <strong>
        {new Intl.NumberFormat("th-TH", {
          style: "currency",
          currency: "THB",
        }).format(ppu)}
      </strong>
      <span class="text-sm text-gray-600"> / หน่วย</span>
    </p>
  </form>
</div>
