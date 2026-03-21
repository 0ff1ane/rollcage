<script lang="ts">
    let props = $props();

    let todos = $state([
        { text: "Complete svelte tutorial", complete: true },
        { text: "Build todo app", complete: true },
        { text: "Read TypeScript documentation", complete: false },
        { text: "Write unit tests", complete: false },
        { text: "Deploy to production", complete: false },
    ]);
    let newTodoText = $state("");
    let isValidTodoText = $derived(newTodoText.length > 5);

    function addTodo() {
        todos.unshift({ text: newTodoText, complete: false });
        newTodoText = "";
    }

    function deleteTodo(idx: number) {
        todos.splice(idx, 1);
    }
</script>

<div class="relative py-12 max-w-md mx-auto">
    <div class="bg-white p-8 rounded-lg shadow-lg w-full flex flex-col gap-4">
        <h1 class="text-2xl text-gray-800 mb-6 text-center">Todo App</h1>

        <div>
            <div class="flex">
                <input
                    type="text"
                    placeholder="Add a new todo"
                    class="flex-grow p-3 border border-gray-300 rounded-l-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    bind:value={newTodoText}
                    onkeydown={(e) => {
                        if (e.key === "Enter") addTodo();
                    }}
                />
                <button
                    onclick={addTodo}
                    disabled={!isValidTodoText}
                    class={`bg-gray-600 text-white p-3 rounded-r-lg hover:bg-gray-700 transition-colors duration-200 text-sm ${isValidTodoText ? "cursor-pointer" : "cursor-not-allowed"}`}
                >
                    Add
                </button>
            </div>
            {#if newTodoText.length > 0 && !isValidTodoText}
                <span class="text-red-500 text-xs"
                    >Must be atleast 5 letters long</span
                >
            {/if}
        </div>

        {#if todos.length === 0}
            <p class="text-gray-500 text-center">
                No todos yet. Add one above!
            </p>
        {:else}
            <ul>
                {#each todos as todo, index (index)}
                    <li
                        class="flex items-center justify-between bg-gray-50 p-3 rounded-lg mb-2 shadow-sm"
                    >
                        <input
                            type="checkbox"
                            bind:checked={todo.complete}
                            class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded cursor-pointer"
                        />
                        <span
                            class="ml-2 flex-grow text-lg {todo.complete
                                ? 'line-through text-gray-500'
                                : 'text-gray-800'}"
                        >
                            {todo.text}
                        </span>
                        <button
                            class="ml-4 text-red-500 hover:text-red-700 transition-colors duration-200 text-lg cursor-pointer"
                            onclick={() => deleteTodo(index)}
                        >
                            &#10007;
                        </button>
                    </li>
                {/each}
            </ul>
        {/if}
    </div>
</div>

<div class="mx-auto max-w-2xl text-center pb-12">
    inertia props = {JSON.stringify(props)}
</div>
