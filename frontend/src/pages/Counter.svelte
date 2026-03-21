<script lang="ts">
    let props = $props();
    let count = $state(0);

    function decrement() {
        if (count > 0) {
            count = count - 1;
        }
    }

    function increment() {
        count = count + 1;
    }
</script>

<div
    class="max-w-2xl h-full mx-auto my-24 py-24 bg-white shadow-xl rounded-lg flex flex-col items-center gap-5"
>
    <div class="text-lg">Simple Counter</div>
    <div class="flex gap-5 justify-center">
        <button
            class={`text-2xl ${count === 0 ? "cursor-not-allowed" : "cursor-pointer"}`}
            onclick={decrement}>&#8722;</button
        >
        <div class="text-2xl text-red-500 min-w-12 text-center">{count}</div>
        <button class="cursor-pointer text-2xl" onclick={increment}
            >&#43;</button
        >
    </div>
</div>

<div class="max-w-2xl mx-auto text-center">
    inertia props = {JSON.stringify(props)}
</div>
