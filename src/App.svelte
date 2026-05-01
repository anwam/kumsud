<script>
  // import html2canvas from "html2canvas";
  import GitBranch from 'lucide-svelte/icons/git-branch'
  import Plus from 'lucide-svelte/icons/plus'
  import Comparator from './components/Comparator.svelte'

  const STORAGE_KEY = 'kumsud:comparators'

  /** @param {number} id */
  const createComparator = id => ({
    id,
    title: '',
    ppu: 0,
    price: 0,
    vol: 1,
    quantity: 1,
    promoEnabled: false,
    promoType: 'none',
    percentOff: 0,
    fixedOff: 0,
    buyQty: 1,
    getQty: 1,
  })

  const defaultComparators = [createComparator(1), createComparator(2)]

  /** @param {Record<string, any>} raw */
  const normalizeComparator = raw => ({
    ...createComparator(Number(raw?.id) > 0 ? Number(raw.id) : 1),
    ...raw,
    id: Number(raw?.id) > 0 ? Number(raw.id) : 1,
    title: typeof raw?.title === 'string' ? raw.title : '',
    ppu: Number.isFinite(Number(raw?.ppu)) ? Number(raw.ppu) : 0,
    price: Number.isFinite(Number(raw?.price)) ? Number(raw.price) : 0,
    vol: Number(raw?.vol) > 0 ? Number(raw.vol) : 1,
    quantity: Number(raw?.quantity) > 0 ? Number(raw.quantity) : 1,
    promoEnabled: Boolean(raw?.promoEnabled),
    promoType: typeof raw?.promoType === 'string' ? raw.promoType : 'none',
    percentOff: Number.isFinite(Number(raw?.percentOff)) ? Number(raw.percentOff) : 0,
    fixedOff: Number.isFinite(Number(raw?.fixedOff)) ? Number(raw.fixedOff) : 0,
    buyQty: Number(raw?.buyQty) > 0 ? Number(raw.buyQty) : 1,
    getQty: Number(raw?.getQty) > 0 ? Number(raw.getQty) : 1,
  })

  const loadComparators = () => {
    if (typeof localStorage === 'undefined') {
      return defaultComparators
    }

    try {
      const raw = localStorage.getItem(STORAGE_KEY)
      if (!raw) {
        return defaultComparators
      }

      const parsed = JSON.parse(raw)
      if (!Array.isArray(parsed) || parsed.length === 0) {
        return defaultComparators
      }

      return parsed.map(c => normalizeComparator(c))
    }
    catch {
      return defaultComparators
    }
  }

  let comparators = $state(loadComparators())

  $effect(() => {
    if (typeof localStorage === 'undefined') {
      return
    }

    localStorage.setItem(STORAGE_KEY, JSON.stringify(comparators))
  })

  const addComparator = () => {
    comparators = [
      ...comparators,
      {
        id:
          comparators.length > 0
            ? comparators[comparators.length - 1].id + 1
            : 1,
        ...createComparator(
          comparators.length > 0
            ? comparators[comparators.length - 1].id + 1
            : 1,
        ),
      },
    ]
  }

  const deleteComparator = (/** @type {number} */ id) => {
    return () => {
      comparators = comparators.filter(c => c.id !== id)
    }
  }

  const maxPPU = $derived.by(() => {
    const positive = comparators.filter(c => Number(c.ppu) > 0)
    if (positive.length === 0) {
      return null
    }

    const minPPU = Math.min(...positive.map(c => Number(c.ppu)))
    return positive.find(c => Number(c.ppu) === minPPU) ?? null
  })

  /** @param {number} id */
  const isMinPPU = (id) => {
    return maxPPU !== null && id === maxPPU.id && maxPPU.ppu > 0
  }
</script>

<main
  class='container relative mx-auto flex max-h-dvh min-h-0 max-w-md flex-col gap-1 md:gap-2 p-1 md:p-2 lg:max-w-3xl lg:gap-3 lg:p-3'
>
  <div class='py-3 text-center bg-gray-100 shadow rounded-xl'>
    <h1
      class='text-xl font-extrabold text-center text-transparent title bg-linear-to-b from-red-700 to-pink-400 bg-clip-text lg:text-3xl'
    >
      KUM SUD - คุ้มสุด
    </h1>
    <p class='mt-1 text-sm'>คำนวณราคาสินค้าต่อหน่วย อันไหนคุ้มสุด รู้เลย</p>
  </div>
  <div
    id='comparators'
    class='grid grid-flow-row grid-cols-12 gap-1 overflow-x-auto md:gap-3 touch-auto snap-y snap-mandatory lg:gap-4'
  >
    {#each comparators as c, i (c.id)}
      <Comparator
        bind:product={comparators[i]}
        handleRemove={deleteComparator}
        {isMinPPU}
      />
    {/each}
  </div>

  <div
    class='flex flex-row col-span-12 text-sm text-center place-items-center gap-x-1 text-gray-50'
  >
    <div
      class='box-border flex flex-row gap-1 py-1 pl-1 pr-2 text-center text-gray-600 bg-gray-100 rounded-full shadow w-fit place-items-center place-self-center'
    >
      <a
        href='https://github.com/anwam'
        class='flex flex-row gap-1 place-items-center'
      >
        <span
          class='block p-1 bg-gray-700 rounded-full h-fit w-fit text-gray-50'
        >
          <GitBranch size={12} />
        </span>
        <u>anwam</u>
      </a>
      built with ❤️ and
      <a class='text-orange-700' href='https://svelte.dev/'>svelte.dev</a>
    </div>
    <p
      class='box-border px-2 py-1 text-gray-600 bg-gray-100 rounded-full shadow'
    >
      v.{__APP_VERSION__}
    </p>

    <button
      aria-label='เพิ่มสินค้า'
      class='self-end p-2 ml-auto transition-all duration-300 bg-blue-500 rounded-full w-fit text-blue-50 hover:ring-2 hover:ring-blue-700'
      onclick={addComparator}
    >
      <Plus size={18} />
    </button>
  </div>
  <!-- </div> -->
</main>
