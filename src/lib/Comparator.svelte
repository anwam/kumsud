<script>
  import { Minus } from "lucide-svelte";
  import { slide } from "svelte/transition";

  let price = 0;
  let vol = 1;
  let quantity = 1;
  let showQuan = false;
  export let product;
  export let handleRemove;
  export let isMinPPU;

  $: ppu = price / (showQuan ? vol * quantity : vol);
  $: product = { ...product, ppu };

  const onToggleShowQuan = (e) => {
    console.log({ showQuan });
  };
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
  <div class="flex flex-row flex-wrap justify-between gap-y-2">
    <p class="flex flex-row place-items-center gap-x-2">
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

    <label
      class="relative flex items-center flex-grow flex-shrink-0 w-full cursor-pointer"
    >
      <input
        type="checkbox"
        class="sr-only peer"
        name="show-quan"
        id="show-quan"
        bind:checked={showQuan}
        on:change={onToggleShowQuan}
      />
      <div
        class="w-8 h-5 bg-gray-200 rounded-full peer peer-focus:ring-2 peer-focus:ring-green-500 dark:peer-focus:ring-green-400 dark:bg-gray-400 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-1 after:left-1 after:bg-white after:border-gray-300 after:border after:rounded-full after:h-3 after:w-3 after:transition-all dark:border-gray-600 peer-checked:bg-green-600"
      />
      <span class="ml-1 text-sm font-medium text-gray-400">จำนวน</span>
    </label>
  </div>
  <form class="grid grid-flow-row grid-cols-4 gap-2 text-sm">
    <div class="relative col-span-2 md:col-span-4">
      <label class="text-xs text-gray-600" for={`price-${product.id}`}
        >ราคา (สุทธิ)
      </label>
      <input
        class="w-full p-1 text-base border border-blue-200 rounded"
        on:focus={(e) => e.currentTarget.select()}
        pattern="\d*"
        type="number"
        name="price"
        id={`price-${product.id}`}
        bind:value={price}
      />
      {#if showQuan}
        <span class="absolute text-gray-300 right-2 bottom-2">
          {price / quantity} / ชิ้น
        </span>
      {/if}
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
    {#if showQuan}
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
    {/if}
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
