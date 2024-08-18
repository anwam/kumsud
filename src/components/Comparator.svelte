<script>
  import Check from 'lucide-svelte/icons/check'
  import Minus from 'lucide-svelte/icons/minus'
  import Pen from 'lucide-svelte/icons/pen'
  import Plus from 'lucide-svelte/icons/plus'
  import Trash2 from 'lucide-svelte/icons/trash-2'

  import { fly } from 'svelte/transition'

  let price = 0
  let vol = 1
  let quantity = 1
  let isEditTitle = false
  export let product
  export let handleRemove
  export let isMinPPU

  $: ppu = price / (vol * quantity)
  $: product = { ...product, ppu }

  const handleEditTitle = () => {
    isEditTitle = !isEditTitle
  }
  const increase = () => {
    quantity += 1
  }
  const decrease = () => {
    if (quantity > 1) {
      quantity -= 1
    }
  }

  /** @type {import('svelte/action').Action} */
  const autoFocus = (node) => {
    node.focus()
  }
</script>

<div
  transition:fly={{ y: -100, opacity: 0 }}
  class={`col-span-12 flex snap-start snap-always scroll-my-1 flex-col gap-2 rounded-xl bg-gray-50 p-2 shadow transition-all duration-100 lg:col-span-6 lg:gap-4 lg:p-4 ${
    isMinPPU(product.id) ? 'ring-2 ring-lime-200' : ''
  }`}
>
  <div class='flex flex-row justify-between'>
    <p class='flex flex-row place-items-center gap-x-2'>
      {#if isEditTitle}
        <input
          aria-label='ช่องกรอก ชื่อสินค้า'
          type='text'
          name='title-input'
          id='title-input'
          placeholder='ชื่อสินค้า'
          class='px-2 py-0.5 text-base text-blue-700 border border-blue-200 rounded w-fit placeholder:text-sm placeholder:text-blue-200'
          bind:value={product.title}
          on:keypress={(/** @type {KeyboardEvent} */ e) => {
            if (e.key === 'Enter') {
              handleEditTitle()
            }
          }}
          use:autoFocus
        />
        <button type='button' class='p-1.5 text-green-600 transition-all duration-200 border rounded w-fit hover:bg-blue-200' on:click|preventDefault={handleEditTitle}>
          <Check size={12} />
        </button>
      {:else if product.title !== ''}
        <span aria-label='ชื่อสินค้า' tabindex={-1} role='textbox' on:dblclick|preventDefault={handleEditTitle}>
          {product.title}
        </span>
      {:else}
        <span tabindex={-1} role='textbox' on:dblclick|preventDefault={handleEditTitle}>
          {`# ${product.id}`}
          {#if isMinPPU(product.id)}
            <span>คุ้มกว่า</span>
          {/if}
        </span>
      {/if}
    </p>

    <div class='flex flex-row'>
      <button
        type='button'
        aria-label='ปุ่มแก้ไขชื่อสินค้า'
        tabindex='-1'
        class='p-2 text-blue-600 transition-all duration-200 border-l rounded-l-lg w-fit border-y hover:bg-blue-200'
        on:click|preventDefault={handleEditTitle}
      >
        <Pen size={12} />
      </button>
      <div class='w-[1px] bg-gray-200' />
      <button
        type='button'
        aria-label='ปุ่มลบสินค้า'
        tabindex='-1'
        class='p-2 text-red-600 transition-all duration-200 border-r rounded-r-lg w-fit border-y hover:bg-red-200'
        on:click|preventDefault={handleRemove(product.id)}
      >
        <Trash2 size={12} />
      </button>
    </div>
  </div>
  <form class='grid grid-flow-row grid-cols-4 gap-2 text-sm'>
    <div class='relative flex flex-col col-span-4 gap-y-2'>
      <label
        class='text-xs text-gray-600'
        for={`price-${product.id}`}
      >
        ราคา (สุทธิ)
      </label>
      <div class='flex flex-row'>
        <input
          aria-label='ช่องกรอก ราคา'
          class='flex-grow min-w-0 p-2 text-base border border-blue-200 rounded-l-lg rounded-r-none'
          pattern='\d*'
          inputmode='decimal'
          type='number'
          name='price'
          id={`price-${product.id}`}
          bind:value={price}
          on:focus={e => e.currentTarget.select()}
          on:contextmenu|preventDefault
        />
        <p
          class='h-full rounded-l-none rounded-r-lg border-y border-r border-blue-200 p-2 text-[9px] leading-6 text-gray-500'
        >
          {new Intl.NumberFormat('th-TH', {
            style: 'currency',
            currency: 'THB',
          }).format(price / quantity)}/ชิ้น
        </p>
      </div>
    </div>
    <div class='flex flex-col col-span-2 gap-y-2'>
      <label class='text-xs text-gray-600' for={`vol-${product.id}`}
      >ปริมาณ</label
      >
      <input
        aria-label='ช่องกรอก ปริมาณ'
        class='w-full p-2 text-base border border-blue-200 rounded-xl text-end'
        on:focus|preventDefault={e => e.currentTarget.select()}
        on:contextmenu|preventDefault
        pattern='\d*'
        inputmode='decimal'
        type='number'
        name='vol'
        id={`vol-${product.id}`}
        bind:value={vol}
      />
    </div>
    <div class='flex flex-col col-span-2 gap-y-2'>
      <label class='text-xs text-gray-600' for={`quant-${product.id}`}
      >จำนวน (ชิ้น)</label
      >
      <div class='box-border flex flex-row'>
        <button
          type='button'
          aria-label='ลดจำนวน'
          class='box-border px-3 border-l border-y rounded-l-xl border-lime-400 text-lime-600 hover:bg-lime-50'
          on:click|preventDefault={decrease}
        >
          <Minus size={12} />
        </button>
        <input
          id={`quant-${product.id}`}
          aria-label='จำนวน'
          class='min-w-0 p-2 text-base rounded-none border-y border-x border-lime-400 text-end'
          pattern='\d*'
          type='number'
          name='quant'
          on:focus={e => e.currentTarget.select()}
          on:contextmenu|preventDefault
          bind:value={quantity}
        />
        <button
          type='button'
          aria-label='เพิ่มจำนวน'
          on:click|preventDefault={increase}
          class='box-border px-3 border-r border-y rounded-r-xl border-lime-400 text-lime-600 hover:bg-lime-50'
        >
          <Plus size={12} />
        </button>
      </div>
    </div>
    <p
      class='flex flex-row col-span-4 text-lg place-items-center'
      id={`ppu-${product.id}`}
      aria-label='ราคาต่อหน่วย'
    >
      {#if isMinPPU(product.id)}
        <span
          class='inline-block p-2 mr-2 text-green-600 bg-green-300 rounded-full'
        >
          <Check size={16} />
        </span>
      {/if}
      <strong>
        {new Intl.NumberFormat('th-TH', {
          style: 'currency',
          currency: 'THB',
        }).format(ppu)}
      </strong>
      <span class='text-sm text-gray-600'>/หน่วย</span>
    </p>
  </form>
</div>
