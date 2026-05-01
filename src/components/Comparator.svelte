<script>
  import Check from 'lucide-svelte/icons/check'
  import Minus from 'lucide-svelte/icons/minus'
  import Pen from 'lucide-svelte/icons/pen'
  import Plus from 'lucide-svelte/icons/plus'
  import Trash2 from 'lucide-svelte/icons/trash-2'

  import { fly } from 'svelte/transition'

  let { product = $bindable(), handleRemove, isMinPPU } = $props()

  let price = $state(Number(product.price) || 0)
  let vol = $state(Number(product.vol) > 0 ? Number(product.vol) : 1)
  let quantity = $state(Number(product.quantity) > 0 ? Number(product.quantity) : 1)
  let isEditTitle = $state(false)
  let promoEnabled = $state(Boolean(product.promoEnabled))
  let promoType = $state(typeof product.promoType === 'string' ? product.promoType : 'none')
  let percentOff = $state(Number(product.percentOff) || 0)
  let fixedOff = $state(Number(product.fixedOff) || 0)
  let buyQty = $state(Number(product.buyQty) > 0 ? Number(product.buyQty) : 1)
  let getQty = $state(Number(product.getQty) > 0 ? Number(product.getQty) : 1)

  const baseUnits = $derived(Number(vol) * Number(quantity))
  const basePPU = $derived(baseUnits > 0 ? Number(price) / baseUnits : 0)
  const isPromoActive = $derived(promoEnabled && promoType !== 'none')
  const promoError = $derived.by(() => {
    if (!isPromoActive) {
      return ''
    }

    if (baseUnits <= 0 || Number(price) < 0) {
      return 'กรอกข้อมูลราคา ปริมาณ และจำนวนให้ถูกต้องก่อน'
    }

    if (promoType === 'percent') {
      if (Number(percentOff) <= 0 || Number(percentOff) >= 100) {
        return 'ส่วนลดเปอร์เซ็นต์ต้องมากกว่า 0 และน้อยกว่า 100'
      }
    }

    if (promoType === 'fixed') {
      if (Number(fixedOff) < 0 || Number(fixedOff) > Number(price)) {
        return 'ส่วนลดคงที่ต้องอยู่ระหว่าง 0 ถึงราคาสินค้า'
      }
    }

    if (promoType === 'buyxgety') {
      if (!Number.isInteger(Number(buyQty)) || Number(buyQty) < 1) {
        return 'จำนวนซื้อ (X) ต้องเป็นจำนวนเต็มตั้งแต่ 1 ขึ้นไป'
      }

      if (!Number.isInteger(Number(getQty)) || Number(getQty) < 1) {
        return 'จำนวนแถม (Y) ต้องเป็นจำนวนเต็มตั้งแต่ 1 ขึ้นไป'
      }
    }

    return ''
  })
  const effectivePrice = $derived.by(() => {
    if (!isPromoActive || promoError) {
      return Number(price)
    }

    if (promoType === 'percent') {
      return Number(price) * (1 - Number(percentOff) / 100)
    }

    if (promoType === 'fixed') {
      return Math.max(0, Number(price) - Number(fixedOff))
    }

    return Number(price)
  })
  const effectiveUnits = $derived.by(() => {
    if (!isPromoActive || promoError) {
      return baseUnits
    }

    if (promoType === 'buyxgety') {
      return baseUnits * ((Number(buyQty) + Number(getQty)) / Number(buyQty))
    }

    return baseUnits
  })
  const finalPPU = $derived(effectiveUnits > 0 ? effectivePrice / effectiveUnits : 0)
  const ppu = $derived(isPromoActive && !promoError ? finalPPU : basePPU)

  $effect(() => {
    product.price = price
    product.vol = vol
    product.quantity = quantity
    product.promoEnabled = promoEnabled
    product.promoType = promoType
    product.percentOff = percentOff
    product.fixedOff = fixedOff
    product.buyQty = buyQty
    product.getQty = getQty
    product.ppu = ppu
  })

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

  const togglePromo = () => {
    promoEnabled = !promoEnabled
    if (!promoEnabled) {
      promoType = 'none'
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
          onkeypress={(/** @type {KeyboardEvent} */ e) => {
            if (e.key === 'Enter') {
              handleEditTitle()
            }
          }}
          use:autoFocus
        />
        <button
          type='button'
          class='p-1.5 text-green-600 transition-all duration-200 border rounded w-fit hover:bg-blue-200'
          onclick={(e) => {
            e.preventDefault()
            handleEditTitle()
          }}
        >
          <Check size={12} />
        </button>
      {:else if product.title !== ''}
        <span
          aria-label='ชื่อสินค้า'
          tabindex={-1}
          role='textbox'
          ondblclick={(e) => {
            e.preventDefault()
            handleEditTitle()
          }}
        >
          {product.title}
        </span>
      {:else}
        <span
          tabindex={-1}
          role='textbox'
          ondblclick={(e) => {
            e.preventDefault()
            handleEditTitle()
          }}
        >
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
        onclick={(e) => {
          e.preventDefault()
          handleEditTitle()
        }}
      >
        <Pen size={12} />
      </button>
      <div class='w-px bg-gray-200'></div>
      <button
        type='button'
        aria-label='ปุ่มลบสินค้า'
        tabindex='-1'
        class='p-2 text-red-600 transition-all duration-200 border-r rounded-r-lg w-fit border-y hover:bg-red-200'
        onclick={(e) => {
          e.preventDefault()
          handleRemove(product.id)()
        }}
      >
        <Trash2 size={12} />
      </button>
    </div>
  </div>
  <form class='grid grid-flow-row grid-cols-4 gap-2 text-sm'>
    <div class='relative flex flex-col col-span-4 gap-y-2'>
      <label class='text-xs text-gray-600' for={`price-${product.id}`}>
        ราคา (สุทธิ)
      </label>
      <div class='flex flex-row'>
        <input
          aria-label='ช่องกรอก ราคา'
          class='grow min-w-0 p-2 text-base border border-blue-200 rounded-l-lg rounded-r-none'
          pattern='\d*'
          inputmode='decimal'
          type='number'
          name='price'
          id={`price-${product.id}`}
          bind:value={price}
          onfocus={e => e.currentTarget.select()}
          oncontextmenu={e => e.preventDefault()}
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
        onfocus={(e) => {
          e.preventDefault()
          e.currentTarget.select()
        }}
        oncontextmenu={e => e.preventDefault()}
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
          onclick={(e) => {
            e.preventDefault()
            decrease()
          }}
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
          onfocus={e => e.currentTarget.select()}
          oncontextmenu={e => e.preventDefault()}
          bind:value={quantity}
        />
        <button
          type='button'
          aria-label='เพิ่มจำนวน'
          onclick={(e) => {
            e.preventDefault()
            increase()
          }}
          class='box-border px-3 border-r border-y rounded-r-xl border-lime-400 text-lime-600 hover:bg-lime-50'
        >
          <Plus size={12} />
        </button>
      </div>
    </div>
    <div class='col-span-4 mt-1 rounded-xl border border-sky-200 bg-sky-50 p-2'>
      <div class='flex items-center justify-between'>
        <p class='text-xs text-sky-800'>โปรโมชัน</p>
        <button
          type='button'
          class='rounded-lg border border-sky-300 px-2 py-1 text-xs text-sky-700 hover:bg-sky-100'
          onclick={(e) => {
            e.preventDefault()
            togglePromo()
          }}
        >
          {promoEnabled ? 'ซ่อนโปรโมชัน' : 'เพิ่มโปรโมชัน'}
        </button>
      </div>

      {#if promoEnabled}
        <div class='mt-2 grid grid-cols-4 gap-2'>
          <div class='col-span-4'>
            <label class='mb-1 block text-xs text-gray-600' for={`promo-type-${product.id}`}>
              ประเภทโปรโมชัน
            </label>
            <select
              id={`promo-type-${product.id}`}
              class='w-full rounded-lg border border-sky-200 p-2 text-sm'
              bind:value={promoType}
            >
              <option value='none'>เลือกโปรโมชัน</option>
              <option value='percent'>ลดเป็นเปอร์เซ็นต์</option>
              <option value='fixed'>ลดราคาคงที่</option>
              <option value='buyxgety'>ซื้อ X แถม Y</option>
            </select>
          </div>

          {#if promoType === 'percent'}
            <div class='col-span-4'>
              <label class='mb-1 block text-xs text-gray-600' for={`percent-off-${product.id}`}>
                เปอร์เซ็นต์ส่วนลด (%)
              </label>
              <input
                id={`percent-off-${product.id}`}
                type='number'
                inputmode='decimal'
                class='w-full rounded-lg border border-sky-200 p-2 text-end'
                onfocus={e => e.currentTarget.select()}
                oncontextmenu={e => e.preventDefault()}
                bind:value={percentOff}
              />
            </div>
          {/if}

          {#if promoType === 'fixed'}
            <div class='col-span-4'>
              <label class='mb-1 block text-xs text-gray-600' for={`fixed-off-${product.id}`}>
                ลดราคาคงที่ (บาท)
              </label>
              <input
                id={`fixed-off-${product.id}`}
                type='number'
                inputmode='decimal'
                class='w-full rounded-lg border border-sky-200 p-2 text-end'
                onfocus={e => e.currentTarget.select()}
                oncontextmenu={e => e.preventDefault()}
                bind:value={fixedOff}
              />
            </div>
          {/if}

          {#if promoType === 'buyxgety'}
            <div class='col-span-2'>
              <label class='mb-1 block text-xs text-gray-600' for={`buy-qty-${product.id}`}>
                ซื้อ (X)
              </label>
              <input
                id={`buy-qty-${product.id}`}
                type='number'
                class='w-full rounded-lg border border-sky-200 p-2 text-end'
                onfocus={e => e.currentTarget.select()}
                oncontextmenu={e => e.preventDefault()}
                bind:value={buyQty}
              />
            </div>
            <div class='col-span-2'>
              <label class='mb-1 block text-xs text-gray-600' for={`get-qty-${product.id}`}>
                แถม (Y)
              </label>
              <input
                id={`get-qty-${product.id}`}
                type='number'
                class='w-full rounded-lg border border-sky-200 p-2 text-end'
                onfocus={e => e.currentTarget.select()}
                oncontextmenu={e => e.preventDefault()}
                bind:value={getQty}
              />
            </div>
          {/if}

          {#if promoError}
            <p class='col-span-4 rounded-lg bg-red-100 px-2 py-1 text-xs text-red-700'>
              {promoError}
            </p>
          {/if}
        </div>
      {/if}
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
      <span class='text-sm text-gray-600'>/หน่วย {isPromoActive && !promoError ? '(หลังโปร)' : ''}</span>
    </p>
    {#if isPromoActive}
      <div class='col-span-4 grid grid-cols-1 gap-1 rounded-lg bg-gray-100 p-2 text-xs text-gray-700'>
        <p>
          ราคาต่อหน่วย (ปกติ):
          <strong>
            {new Intl.NumberFormat('th-TH', {
              style: 'currency',
              currency: 'THB',
            }).format(basePPU)}
          </strong>
          /หน่วย
        </p>
        <p>
          ราคาต่อหน่วย (หลังโปร):
          <strong>
            {new Intl.NumberFormat('th-TH', {
              style: 'currency',
              currency: 'THB',
            }).format(finalPPU)}
          </strong>
          /หน่วย
        </p>
      </div>
    {/if}
  </form>
</div>
