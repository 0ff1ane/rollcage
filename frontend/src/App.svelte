<script lang="ts">
  let lineNumber = $state(32);
</script>

<main>
    <div class="max-w-md bg-white mx-auto my-20 p-5 shadow-xl">
        <div class="text-red-500">Roses are red</div>
        <div class="text-violet-500">Violets are blue</div>
        <div class="text-gray-600">Cannot Read Property of Undefined</div>
        <div class="text-gray-600">
            On <span class="underline">line {lineNumber}</span>
        </div>
    </div>
</main>
