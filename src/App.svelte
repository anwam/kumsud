<script>
  // import html2canvas from "html2canvas";
  import { Plus, Minus, Github } from "lucide-svelte";
  import { slide } from "svelte/transition";
  import Comparator from "./lib/Comparator.svelte";

  let comparators = [
    { id: 1, ppu: 0, title: "" },
    { id: 2, ppu: 0, title: "" },
  ];

  const addComparator = () => {
    comparators = [
      ...comparators,
      {
        id:
          comparators.length > 0
            ? comparators[comparators.length - 1].id + 1
            : 1,
        ppu: 0,
        title: "",
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

  // const download = () => {
  //   const el = document.getElementById("comparators");
  //   html2canvas(el).then((canvas) => {
  //     const link = document.createElement("a");
  //     link.download = "kum-sud.png";
  //     link.href = canvas.toDataURL("png");
  //     link.click();
  //   });
  // };

  $: maxPPU = comparators.find(
    (c) => c.ppu === Math.min(...comparators.map((c) => c.ppu))
  );
</script>

<main
  class="container relative flex flex-col max-w-md lg:max-w-3xl max-h-[100dvh] gap-2 p-2 md:gap-3 md:p-3 mx-auto"
>
  <div class="py-1 mx-1 text-center bg-gray-100 rounded-lg shadow md:py-3">
    <h1
      class="text-xl font-extrabold text-center text-transparent title md:text-2xl lg:text-3xl bg-gradient-to-b from-red-700 to-pink-400 bg-clip-text"
    >
      KUM SUD - คุ้มสุด
    </h1>
    <p class="mt-1 text-sm">คำนวณราคาสินค้าต่อหน่วย อันไหนคุ้มสุด รู้เลย</p>
  </div>

  <div
    class="fixed flex flex-row text-sm text-center gap-x-1 text-gray-50 top-1 right-1"
  >
    <a
      href="https://github.com/anwam"
      class="box-border flex flex-row gap-1 py-1 pl-1 pr-2 text-center text-gray-600 bg-gray-100 rounded-full shadow place-self-center place-items-center w-fit"
    >
      <span class="block p-1 bg-gray-700 rounded-full w-fit h-fit text-gray-50">
        <Github size={12} />
      </span>
      anwam
    </a>
    <!-- svelte-ignore missing-declaration -->
    <p
      class="box-border px-2 py-1 text-gray-600 bg-gray-100 rounded-full shadow"
    >
      {__APP_VERSION__}
    </p>
  </div>
  <div
    id="comparators"
    class="grid grid-flow-row grid-cols-12 gap-3 p-1 overflow-auto lg:gap-4 scroll-smooth snap-y touch-auto"
  >
    {#each comparators as c (c.id)}
      <Comparator bind:product={c} handleRemove={deleteComparator} {isMinPPU} />
    {/each}
  </div>

  <!-- <div class="flex flex-row self-end gap-x-2"> -->
  <!-- <button
      on:click={download}
      class="p-2 transition-all duration-300 bg-blue-500 rounded-full w-fit text-blue-50 hover:ring-2 hover:ring-blue-700"
    >
      <Download size={18} />
    </button> -->
  <button
    class="self-end p-2 transition-all duration-300 bg-blue-500 rounded-full w-fit text-blue-50 hover:ring-2 hover:ring-blue-700"
    on:click={addComparator}
  >
    <Plus size={18} />
  </button>
  <!-- </div> -->
</main>
