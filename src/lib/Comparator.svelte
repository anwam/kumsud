<script>
  import { Check, Minus, Pen } from "lucide-svelte";
  import { slide } from "svelte/transition";

  let price = 0;
  let vol = 1;
  let quantity = 1;
  let isEditTitle = false;
  // let showQuan = false;
  export let product;
  export let handleRemove;
  export let isMinPPU;

  $: ppu = price / (vol * quantity);
  $: product = { ...product, ppu };

  const handleEditTitle = () => {
    isEditTitle = !isEditTitle;
  };
</script>

<div
  transition:slide={{
    duration: 250,
    delay: 50,
    axis: "y",
  }}
  class={`relative z-0 snap-start scroll-my-2 transition-all duration-300 col-span-12 md:col-span-6 bg-gray-50 border border-gray-400 shadow p-2 md:p-4 gap-2 lg:gap-4 flex flex-col rounded-lg ${
    isMinPPU(product.id) ? "ring-2 ring-lime-200  to-lime-50" : ""
  }`}
>
  <!-- {#if isMinPPU(product.id)} -->
  <!-- <div
    class="absolute z-10 p-3 text-green-200 bg-transparent bg-green-500 rounded-full -top-2 -right-1"
  >
    <Check size={16} />
  </div> -->
  <!-- {/if} -->
  <div class="flex flex-row justify-between">
    <p class="flex flex-row place-items-center gap-x-2">
      {#if isEditTitle}
        <input
          type="text"
          name="title-input"
          id="title-input"
          placeholder="ชื่อสินค้า"
          class="w-full px-2 text-base border border-blue-200 rounded-md placeholder:text-sm placeholder:text-blue-200"
          bind:value={product.title}
          on:keypress={(e) => {
            if (e.key === "Enter") {
              handleEditTitle();
            }
          }}
        />
      {:else if product.title !== ""}
        {product.title}
      {:else}
        {`# ${product.id}`}
        {#if isMinPPU(product.id)}
          <span>คุ้มกว่า</span>
        {/if}
      {/if}
    </p>

    <div class="flex flex-row gap-x-2">
      <button
        tabindex="-1"
        class="p-2 text-blue-600 transition-all duration-300 bg-blue-100 rounded-full w-fit hover:ring-2 hover:ring-blue-200"
        on:click|preventDefault={handleEditTitle}
      >
        <Pen size={12} />
      </button>
      <button
        tabindex="-1"
        class="p-2 text-red-600 transition-all duration-300 bg-red-100 rounded-full w-fit hover:ring-2 hover:ring-red-200"
        on:click|preventDefault={handleRemove(product.id)}
      >
        <Minus size={12} />
      </button>
    </div>
  </div>
  <form class="grid grid-flow-row grid-cols-4 gap-2 text-sm">
    <div class="relative flex flex-col col-span-4 mb-5 gap-y-2">
      <label class="text-xs text-gray-600" for={`price-${product.id}`}
        >ราคา (สุทธิ)
      </label>
      <input
        class="w-full p-2 text-base border border-blue-200 rounded-xl"
        pattern="\d*"
        inputmode="decimal"
        type="number"
        name="price"
        id={`price-${product.id}`}
        bind:value={price}
        on:focus={(e) => e.currentTarget.select()}
      />
      <span class="absolute text-[10px] text-gray-400 left-1 top-full pt-1">
        {new Intl.NumberFormat("th-TH", {
          style: "currency",
          currency: "THB",
        }).format(price / quantity)}/ชิ้น
      </span>
    </div>
    <div class="flex flex-col col-span-2 gap-y-2">
      <label class="text-xs text-gray-600" for={`vol-${product.id}`}
        >ปริมาตร</label
      >
      <input
        class="w-full p-2 text-base border border-yellow-400 rounded-xl text-end"
        on:focus={(e) => e.currentTarget.select()}
        pattern="\d*"
        inputmode="decimal"
        type="number"
        name="vol"
        id={`vol-${product.id}`}
        bind:value={vol}
      />
    </div>
    <div class="flex flex-col col-span-2 gap-y-2">
      <label class="text-xs text-gray-600" for={`quant-${product.id}`}
        >จำนวน (ชิ้น)</label
      >
      <input
        class="w-full p-2 text-base border rounded-xl text-end border-lime-400"
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
