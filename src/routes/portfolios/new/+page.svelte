<script lang="ts">
	import { goto } from '$app/navigation';
	import { trpc } from '$lib/trpc/client';

	let name = '';
	let creating = false;
	let error: string | null = null;

	async function createPortfolio() {
		if (!name.trim()) {
			error = 'Please enter a portfolio name';
			return;
		}

		creating = true;
		error = null;

		try {
			const result = await trpc.portfolios.create.mutate({ name: name.trim() });
			goto(`/portfolios/${result.id}`);
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to create portfolio';
			creating = false;
		}
	}
</script>

<div class="min-h-screen bg-gray-50">
	<header class="bg-white shadow">
		<div class="mx-auto max-w-7xl px-4 py-6">
			<div class="flex items-center gap-4">
				<a href="/" class="text-gray-500 hover:text-gray-700">&larr; Back</a>
				<h1 class="text-3xl font-bold text-gray-900">New Portfolio</h1>
			</div>
		</div>
	</header>

	<main class="mx-auto max-w-xl px-4 py-8">
		{#if error}
			<div class="mb-6 rounded-lg bg-red-50 p-4 text-red-700">
				<p>{error}</p>
			</div>
		{/if}

		<div class="rounded-lg bg-white p-6 shadow">
			<form onsubmit={(e) => { e.preventDefault(); createPortfolio(); }}>
				<label class="block">
					<span class="text-sm font-medium text-gray-700">Portfolio Name</span>
					<input
						type="text"
						bind:value={name}
						placeholder="e.g., Conservative, Growth, Retirement..."
						class="mt-1 block w-full rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
						autofocus
					/>
				</label>

				<p class="mt-4 text-sm text-gray-500">
					A portfolio is a configuration that organizes your holdings into sleeves with budget targets.
					You can create multiple portfolios to compare different strategies.
				</p>

				<div class="mt-6 flex justify-end gap-3">
					<a href="/" class="rounded bg-gray-100 px-4 py-2 text-gray-700 hover:bg-gray-200">
						Cancel
					</a>
					<button
						type="submit"
						disabled={creating}
						class="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:opacity-50"
					>
						{creating ? 'Creating...' : 'Create Portfolio'}
					</button>
				</div>
			</form>
		</div>
	</main>
</div>
