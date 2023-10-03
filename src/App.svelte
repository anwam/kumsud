<script>
  import Comparator from "./lib/Comparator.svelte";
  import { Plus, Minus } from "lucide-svelte";

  let comparators = [
    { id: 1, ppu: 0 },
    { id: 2, ppu: 0 },
  ];
  const addComparator = () => {
    comparators = [
      ...comparators,
      {
        id: comparators.length + 1,
        ppu: 0,
      },
    ];
  };

  const deleteComparator = (/** @type {number} */ id) => {
    return () => {
      comparators = comparators.filter((c) => c.id !== id);
    };
  };

  const isMinPPU = (/** @type {number} */ id) => {
    return id === maxPPU.id && maxPPU.ppu > 0;
  };

  $: maxPPU = comparators.find(
    (c) => c.ppu === Math.min(...comparators.map((c) => c.ppu))
  );
</script>

<main
  class="container flex flex-col max-w-md max-h-[100dvh] gap-4 p-4 mx-auto bg-gray-200 shadow shadow-gray-500"
>
  <h1 class="text-lg font-bold text-center md:text-xl lg:text-2xl">KUM SUD</h1>
  <p class="px-4 py-2 text-xs text-center bg-gray-100 rounded-lg shadow">
    คำนวนราคาสินค้าต่อหน่วย อันไหนคุ้มสุด กดเลย
  </p>
  <div
    class="grid grid-flow-row grid-cols-12 gap-3 py-3 overflow-y-auto scroll-smooth snap-y touch-auto"
  >
    {#each comparators as c, index}
      <div
        class={`snap-start scroll-my-2 transition-all duration-300 col-span-12 md:col-span-6 bg-gray-50 shadow p-2 gap-2 flex flex-col rounded-lg ${
          isMinPPU(c.id) ? "ring-2 ring-blue-200" : ""
        }`}
      >
        <div class="flex flex-row justify-between">
          <p>
            {`สินค้าชิ้นที่ ${index + 1}`}
            {#if isMinPPU(c.id)}
              <span>คุ้มกว่า</span>
            {/if}
          </p>
          <button
            class="p-2 text-red-600 transition-all duration-300 bg-red-100 rounded-full w-fit hover:ring-2 hover:ring-red-200"
            on:click={deleteComparator(c.id)}
          >
            <Minus size={12} />
          </button>
        </div>
        <Comparator id={c.id} bind:product={c} />
      </div>
    {/each}
  </div>
  <button
    class="self-end p-2 transition-all duration-300 bg-blue-500 rounded-full w-fit text-blue-50 hover:ring-2 hover:ring-blue-700"
    on:click={addComparator}
  >
    <Plus size={18} />
  </button>
</main>

<style>
</style>
