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
    (c) => c.ppu === Math.min(...comparators.map((c) => c.ppu)),
  );
</script>

<main
  class="container relative mx-auto flex max-h-[100dvh] min-h-0 max-w-md flex-col gap-2 p-2 lg:max-w-3xl lg:gap-3 lg:p-3"
>
  <div class="mx-1 rounded-xl bg-gray-100 py-1 text-center shadow lg:py-3">
    <h1
      class="title bg-gradient-to-b from-red-700 to-pink-400 bg-clip-text text-center text-xl font-extrabold text-transparent lg:text-3xl"
    >
      KUM SUD - คุ้มสุด
    </h1>
    <p class="mt-1 text-sm">คำนวณราคาสินค้าต่อหน่วย อันไหนคุ้มสุด รู้เลย</p>
  </div>
  <div
    id="comparators"
    class="grid min-h-0 touch-auto snap-y snap-mandatory grid-flow-row grid-cols-12 gap-3 overflow-x-auto p-1 lg:gap-4"
  >
    {#each comparators as c (c.id)}
      <Comparator bind:product={c} handleRemove={deleteComparator} {isMinPPU} />
    {/each}
  </div>

  <!-- <div class="flex flex-row self-end gap-x-2"> -->
  <!-- <button
      on:click={download}
      class="p-2 bg-blue-500 rounded-full transition-all duration-300 w-fit text-blue-50 hover:ring-2 hover:ring-blue-700"
    >
      <Download size={18} />
    </button> -->
  <div
    class="col-span-12 flex flex-row place-items-center gap-x-1 text-center text-sm text-gray-50"
  >
    <a
      href="https://github.com/anwam"
      class="box-border flex w-fit flex-row place-items-center gap-1 place-self-center rounded-full bg-gray-100 py-1 pl-1 pr-2 text-center text-gray-600 shadow"
    >
      <span class="block h-fit w-fit rounded-full bg-gray-700 p-1 text-gray-50">
        <Github size={12} />
      </span>
      <u>anwam</u> built with ❤️ and
      <a class="text-orange-700" href="https://svelte.dev/">svelte.dev</a>
    </a>
    <!-- svelte-ignore missing-declaration -->
    <p
      class="box-border rounded-full bg-gray-100 px-2 py-1 text-gray-600 shadow"
    >
      v.{__APP_VERSION__}
    </p>

    <button
      aria-label="เพิ่มสินค้า"
      class="ml-auto w-fit self-end rounded-full bg-blue-500 p-2 text-blue-50 transition-all duration-300 hover:ring-2 hover:ring-blue-700"
      on:click={addComparator}
    >
      <Plus size={18} />
    </button>
  </div>
  <!-- </div> -->
</main>
