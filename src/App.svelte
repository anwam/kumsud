<script>
  // import html2canvas from "html2canvas";
  import { Github, Plus } from 'lucide-svelte'
  import Comparator from './components/Comparator.svelte'

  let comparators = [
    { id: 1, ppu: 0, title: '' },
    { id: 2, ppu: 0, title: '' },
  ]

  const addComparator = () => {
    comparators = [
      ...comparators,
      {
        id:
          comparators.length > 0
            ? comparators[comparators.length - 1].id + 1
            : 1,
        ppu: 0,
        title: '',
      },
    ]
  }

  const deleteComparator = (/** @type {number} */ id) => {
    return () => {
      comparators = comparators.filter(c => c.id !== id)
    }
  }

  $: maxPPU = comparators.find(
    c => c.ppu === Math.min(...comparators.map(c => c.ppu)),
  )

  /** @param {number} id */
  const isMinPPU = (id) => {
    return id === maxPPU.id && maxPPU.ppu > 0
  }

</script>

<main
  class='container relative mx-auto flex max-h-[100dvh] min-h-0 max-w-md flex-col gap-2 p-2 lg:max-w-3xl lg:gap-3 lg:p-3'
>
  <div class='py-1 mx-1 text-center bg-gray-100 shadow rounded-xl lg:py-3'>
    <h1
      class='text-xl font-extrabold text-center text-transparent title bg-gradient-to-b from-red-700 to-pink-400 bg-clip-text lg:text-3xl'
    >
      KUM SUD - คุ้มสุด
    </h1>
    <p class='mt-1 text-sm'>คำนวณราคาสินค้าต่อหน่วย อันไหนคุ้มสุด รู้เลย</p>
  </div>
  <div
    id='comparators'
    class='grid grid-flow-row grid-cols-12 gap-3 p-1 overflow-x-auto touch-auto snap-y snap-mandatory lg:gap-4'
  >
    {#each comparators as c (c.id)}
      <Comparator bind:product={c} handleRemove={deleteComparator} {isMinPPU} />
    {/each}
  </div>

  <div
    class='flex flex-row col-span-12 text-sm text-center place-items-center gap-x-1 text-gray-50'
  >
    <a
      href='https://github.com/anwam'
      class='box-border flex flex-row gap-1 py-1 pl-1 pr-2 text-center text-gray-600 bg-gray-100 rounded-full shadow w-fit place-items-center place-self-center'
    >
      <span class='block p-1 bg-gray-700 rounded-full h-fit w-fit text-gray-50'>
        <Github size={12} />
      </span>
      <u>anwam</u> built with ❤️ and
      <a class='text-orange-700' href='https://svelte.dev/'>svelte.dev</a>
    </a>
    <!-- svelte-ignore missing-declaration -->
    <p
      class='box-border px-2 py-1 text-gray-600 bg-gray-100 rounded-full shadow'
    >
      v.{__APP_VERSION__}
    </p>

    <button
      aria-label='เพิ่มสินค้า'
      class='self-end p-2 ml-auto transition-all duration-300 bg-blue-500 rounded-full w-fit text-blue-50 hover:ring-2 hover:ring-blue-700'
      on:click={addComparator}
    >
      <Plus size={18} />
    </button>
  </div>
  <!-- </div> -->
</main>
