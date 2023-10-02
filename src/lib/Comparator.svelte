<script>
  let price = 0;
  let vol = 1;
  export let id;
  export let product;

  $: ppu = price / vol;
  $: product = { ...product, ppu };
</script>

<form class="grid grid-cols-2 grid-flow-row gap-1 text-sm">
  <div class="col-span-1">
    <label for={`price-${id}`}>ราคา</label>
    <input
      class="border border-blue-200 rounded p-1 w-full"
      on:focus={(e) => e.currentTarget.select()}
      type="number"
      name="price"
      id={`price-${id}`}
      bind:value={price}
    />
  </div>
  <div class="col-span-1">
    <label for={`vol-${id}`}>ปริมาณ</label>
    <input
      class="border border-red-200 rounded p-1 w-full"
      on:focus={(e) => e.currentTarget.select()}
      type="number"
      name="vol"
      id={`vol-${id}`}
      bind:value={vol}
    />
  </div>
  <input
    disabled
    class="text-lg font-bold col-span-2"
    type="text"
    id={`ppu-${id}`}
    value={new Intl.NumberFormat("th-TH", {
      style: "currency",
      currency: "THB",
    }).format(ppu) + "/หน่วย"}
  />
</form>
