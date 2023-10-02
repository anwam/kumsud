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
  class="container max-w-md max-h-screen mx-auto flex flex-col gap-4 bg-gray-200 p-4 rounded-xl shadow shadow-gray-500"
>
  <h1 class="text-lg md:text-xl lg:text-2xl text-center font-bold">KUM SUD</h1>
  <p>คำนวนราคาสินค้าต่อหน่วย อันไหนคุ้มสุด กดเลย</p>
  <div
    class="overflow-auto grid grid-flow-row grid-cols-12 gap-3 bg-gray-100 rounded-xl p-3 shadow shadow-gray-400"
  >
    {#each comparators as c, index}
      <div
        class={`transition-all duration-300 col-span-12 md:col-span-6 bg-gray-50 shadow shadow-gray-300 p-2 gap-2 flex flex-col rounded-lg ${
          isMinPPU(c.id) ? "ring-2 ring-blue-200" : ""
        }`}
      >
        <div class="flex flex-row justify-between">
          <p>{`สินค้าชิ้นที่ ${index + 1}`}</p>
          <button
            class="w-fit bg-red-100 text-red-600 p-2 rounded-full hover:ring-2 hover:ring-red-200 transition-all duration-300"
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
    class="w-fit self-end bg-blue-500 text-blue-50 p-2 rounded-full hover:ring-2 hover:ring-blue-700 transition-all duration-300"
    on:click={addComparator}
  >
    <Plus size={18} />
  </button>
</main>

<style>
</style>
