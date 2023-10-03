<script>
  let price = 0;
  let vol = 1;
  export let id;
  export let product;

  $: ppu = price / vol;
  $: product = { ...product, ppu };
</script>

<form class="text-sm grid grid-flow-row grid-cols-2 gap-2">
  <div class="col-span-1">
    <label for={`price-${id}`}>ราคา</label>
    <input
      class="w-full p-1 border border-blue-200 rounded"
      on:focus={(e) => e.currentTarget.select()}
      pattern="\d*"
      type="number"
      name="price"
      id={`price-${id}`}
      bind:value={price}
    />
  </div>
  <div class="col-span-1">
    <label for={`vol-${id}`}>ปริมาณ</label>
    <input
      class="w-full p-1 border border-red-200 rounded"
      on:focus={(e) => e.currentTarget.select()}
      pattern="\d*"
      type="number"
      name="vol"
      id={`vol-${id}`}
      bind:value={vol}
    />
  </div>
  <p class="text-lg font-bold col-span-2" id={`ppu-${id}`}>
    {new Intl.NumberFormat("th-TH", {
      style: "currency",
      currency: "THB",
    }).format(ppu) + " /หน่วย"}
  </p>
</form>
