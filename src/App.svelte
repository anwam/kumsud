<script>
  import Comparator from "./lib/Comparator.svelte";
  import { Plus, Minus, Github } from "lucide-svelte";

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
  class="container relative flex flex-col max-w-md max-h-[100dvh] gap-4 p-4 mx-auto"
>
  <h1
    class="font-extrabold text-center text-transparent text- title md:text-xl lg:text-3xl bg-gradient-to-b from-red-700 to-pink-400 bg-clip-text"
  >
    KUM SUD - คุ้มสุด
  </h1>
  <p class="py-1 mx-1 text-xs text-center bg-gray-100 rounded-lg shadow">
    คำนวนราคาสินค้าต่อหน่วย อันไหนคุ้มสุด รู้เลย
  </p>
  <div
    class="fixed flex flex-row p-1 text-sm text-center text-gray-50 top-1 right-1"
  >
    <a
      href="https://github.com/anwam"
      class="box-border flex flex-row gap-1 p-1 text-center text-gray-600 bg-gray-100 rounded-full shadow place-self-center place-items-center w-fit"
    >
      <span class="block p-1 bg-gray-700 rounded-full w-fit h-fit text-gray-50">
        <Github size={12} />
      </span>
      anwam
    </a>
  </div>
  <div
    class="grid grid-flow-row grid-cols-12 gap-3 px-1 py-3 overflow-auto scroll-smooth snap-y touch-auto"
  >
    {#each comparators as c, index}
      <div
        class={`snap-start scroll-my-2 transition-all duration-300 col-span-12 md:col-span-6 bg-gray-50 shadow p-2 md:p-4 gap-2 flex flex-col rounded-lg ${
          isMinPPU(c.id) ? "ring-2 ring-green-200  to-green-50" : ""
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
