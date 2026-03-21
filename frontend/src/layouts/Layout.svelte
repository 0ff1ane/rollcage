<script lang="ts">
    import { page } from "@inertiajs/svelte";
    import { onMount } from "svelte";
    // `children` is passed by inertiaJS
    // `title` is passed from our controller functions' assign_prop
    let { children, title } = $props();

    // get the page url from inertiaJS page store
    let currentPageUrl = $state<string | null>(null);
    page.subscribe((page) => {
        currentPageUrl = page.url;
    });

    // function to underline(show active) the link for current route
    function pageClasses(url: string) {
        return `text-white text-base ${currentPageUrl === url ? "underline" : ""}`;
    }

    onMount(() => console.log("layout mounted"));
</script>

<svelte:head><title>{title ?? "Page Title"}</title></svelte:head>

<main class="h-screen overflow-scroll bg-gray-200">
    <nav class="bg-gray-800 p-4 flex justify-between items-center">
        <div class="flex gap-3 items-end">
            <div class="text-gray-100 text-lg font-semibold">Sinph</div>
            <a href="/counter" class={pageClasses("/counter")}>Counter</a>
            <a href="/todos" class={pageClasses("/todos")}>Todos</a>
        </div>
        <div class="flex items-center space-x-4">
            <span class="text-white">TODO - username</span>
            <a
                href="/"
                class="bg-gray-200 hover:bg-gray-100 text-gray-800 px-2 py-1 rounded text-sm"
                >Logout</a
            >
        </div>
    </nav>
    <article>
        {@render children()}
    </article>
</main>
