<script>
  import {
    Check,
    Eraser,
    Minus,
    Pen,
    Plus,
    Trash,
    Trash2,
  } from "lucide-svelte";
  import { crossfade, fly, slide } from "svelte/transition";

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
  const increase = () => {
    quantity += 1;
  };
  const decrease = () => {
    if (quantity > 1) {
      quantity -= 1;
    }
  };

  /** @type {import('svelte/action').Action} */
  const autoFocus = (node) => {
    node.focus();
  };
</script>

<div
  transition:fly={{ y: -100, opacity: 0 }}
  class={`col-span-12 flex min-h-0 snap-start snap-always scroll-my-1 flex-col gap-2 rounded-xl  bg-gray-50 p-2 shadow transition-all duration-300 lg:col-span-6 lg:gap-4 lg:p-4 ${
    isMinPPU(product.id) ? "to-lime-50 ring-2  ring-lime-200" : ""
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
          aria-label="ช่องกรอก ชื่อสินค้า"
          type="text"
          name="title-input"
          id="title-input"
          placeholder="ชื่อสินค้า"
          class="w-full rounded-lg border border-blue-200 px-2 text-base placeholder:text-sm placeholder:text-blue-200"
          bind:value={product.title}
          on:keypress={(/** @type {KeyboardEvent} */ e) => {
            if (e.key === "Enter") {
              handleEditTitle();
            }
          }}
          use:autoFocus
        />
      {:else if product.title !== ""}
        <p aria-label="ชื่อสินค้า">
          {product.title}
        </p>
      {:else}
        <p>
          {`# ${product.id}`}
          {#if isMinPPU(product.id)}
            <span>คุ้มกว่า</span>
          {/if}
        </p>
      {/if}
    </p>

    <div class="flex flex-row">
      <button
        aria-label="ปุ่มแก้ไขชื่อสินค้า"
        tabindex="-1"
        class="w-fit rounded-l-lg border-y border-l border-blue-300 bg-blue-100 p-2 text-blue-600 transition-all duration-300 hover:ring-2 hover:ring-blue-200"
        on:click|preventDefault={handleEditTitle}
      >
        <Pen size={12} />
      </button>
      <div class="w-[1px] bg-gray-300" />
      <button
        aria-label="ปุ่มลบสินค้า"
        tabindex="-1"
        class="w-fit rounded-r-lg border-y border-r border-red-300 bg-red-100 p-2 text-red-600 transition-all duration-300 hover:ring-2 hover:ring-red-200"
        on:click|preventDefault={handleRemove(product.id)}
      >
        <Trash2 size={12} />
      </button>
    </div>
  </div>
  <form class="grid grid-flow-row grid-cols-4 gap-2 text-sm">
    <div class="relative col-span-4 flex flex-col gap-y-2">
      <label class="text-xs text-gray-600" for={`price-${product.id}`}
        >ราคา (สุทธิ)
      </label>
      <div class="flex flex-row">
        <input
          aria-label="ช่องกรอก ราคา"
          class="min-w-0 flex-grow rounded-l-lg border border-blue-200 p-2 text-base"
          pattern="\d*"
          inputmode="decimal"
          type="number"
          name="price"
          id={`price-${product.id}`}
          bind:value={price}
          on:focus={(e) => e.currentTarget.select()}
        />
        <p
          class="h-full rounded-r-lg border-y border-r border-blue-200 p-2 align-middle text-xs leading-5"
        >
          <span class="pt-1 text-[10px] text-gray-600">
            {new Intl.NumberFormat("th-TH", {
              style: "currency",
              currency: "THB",
            }).format(price / quantity)}/ชิ้น
          </span>
        </p>
      </div>
    </div>
    <div class="col-span-2 flex flex-col gap-y-2">
      <label class="text-xs text-gray-600" for={`vol-${product.id}`}
        >ปริมาตร</label
      >
      <input
        aria-label="ช่องกรอก ปริมาตร"
        class="w-full rounded-xl border border-yellow-400 p-2 text-end text-base"
        on:focus={(e) => e.currentTarget.select()}
        pattern="\d*"
        inputmode="decimal"
        type="number"
        name="vol"
        id={`vol-${product.id}`}
        bind:value={vol}
      />
    </div>
    <div class="col-span-2 flex flex-col gap-y-2">
      <label class="text-xs text-gray-600" for={`quant-${product.id}`}
        >จำนวน (ชิ้น)</label
      >
      <div class="box-border flex flex-row">
        <button
          aria-label="ลดจำนวน"
          on:click|preventDefault={decrease}
          class="box-border rounded-l-xl border border-lime-400 px-3 text-lime-600 hover:bg-lime-100"
        >
          <Minus size={12} />
        </button>
        <input
          aria-label="จำนวน"
          class="min-w-0 border-y border-lime-400 p-2 text-end text-base"
          on:focus={(e) => e.currentTarget.select()}
          pattern="\d*"
          type="number"
          name="quant"
          id={`quant-${product.id}`}
          bind:value={quantity}
        />
        <button
          aria-label="เพิ่มจำนวน"
          on:click|preventDefault={increase}
          class="box-border rounded-r-xl border border-lime-400 px-3 text-lime-600 hover:bg-lime-100"
        >
          <Plus size={12} />
        </button>
      </div>
    </div>
    <p
      class="col-span-4 flex flex-row place-items-center text-lg"
      id={`ppu-${product.id}`}
      aria-label="ราคาต่อหน่วย"
    >
      {#if isMinPPU(product.id)}
        <span
          class="mr-2 inline-block rounded-full bg-green-300 p-2 text-green-600"
        >
          <Check size={16} />
        </span>
      {/if}
      <strong>
        {new Intl.NumberFormat("th-TH", {
          style: "currency",
          currency: "THB",
        }).format(ppu)}
      </strong>
      <span class="text-sm text-gray-600">/หน่วย</span>
    </p>
  </form>
</div>
