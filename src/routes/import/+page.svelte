<script lang="ts">
	import { trpc } from '$lib/trpc/client';

	let fileInput: HTMLInputElement;
	let csvContent = '';
	let parseResult: Awaited<ReturnType<typeof trpc.import.parseCSV.mutate>> | null = null;
	let importing = false;
	let importResult: Awaited<ReturnType<typeof trpc.import.confirmImport.mutate>> | null = null;
	let error: string | null = null;

	async function handleFileSelect(event: Event) {
		const input = event.target as HTMLInputElement;
		const file = input.files?.[0];
		if (!file) return;

		error = null;
		parseResult = null;
		importResult = null;

		try {
			csvContent = await file.text();
			parseResult = await trpc.import.parseCSV.mutate({ content: csvContent });
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to parse CSV';
		}
	}

	async function confirmImport() {
		if (!parseResult) return;

		importing = true;
		error = null;

		try {
			importResult = await trpc.import.confirmImport.mutate({
				orders: parseResult.orders.map((o) => ({
					...o,
					transactionDate: new Date(o.transactionDate)
				}))
			});
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to import';
		} finally {
			importing = false;
		}
	}

	function reset() {
		csvContent = '';
		parseResult = null;
		importResult = null;
		error = null;
		if (fileInput) fileInput.value = '';
	}
</script>

<div class="min-h-screen bg-gray-50">
	<header class="bg-white shadow">
		<div class="mx-auto max-w-7xl px-4 py-6">
			<div class="flex items-center gap-4">
				<a href="/" class="text-gray-500 hover:text-gray-700">&larr; Back</a>
				<h1 class="text-3xl font-bold text-gray-900">Import Orders</h1>
			</div>
			<p class="mt-1 text-gray-600">Upload a Directa CSV export to import your orders</p>
		</div>
	</header>

	<main class="mx-auto max-w-7xl px-4 py-8">
		{#if error}
			<div class="mb-6 rounded-lg bg-red-50 p-4 text-red-700">
				<p class="font-medium">Error</p>
				<p>{error}</p>
			</div>
		{/if}

		{#if importResult}
			<!-- Import Success -->
			<div class="rounded-lg bg-green-50 p-6">
				<h2 class="text-xl font-semibold text-green-800">Import Successful!</h2>
				<ul class="mt-4 space-y-2 text-green-700">
					<li>Assets created: {importResult.assetsCreated}</li>
					<li>Orders imported: {importResult.ordersCreated}</li>
					{#if importResult.ordersReplaced > 0}
						<li class="text-yellow-700">Orders replaced (re-import): {importResult.ordersReplaced}</li>
					{/if}
					<li>Holdings derived: {importResult.holdingsCount}</li>
				</ul>
				<div class="mt-6 flex gap-4">
					<a href="/" class="rounded bg-green-600 px-4 py-2 text-white hover:bg-green-700">
						Go to Dashboard
					</a>
					<button onclick={reset} class="rounded bg-gray-200 px-4 py-2 text-gray-700 hover:bg-gray-300">
						Import Another
					</button>
				</div>
			</div>
		{:else if parseResult}
			<!-- Preview -->
			<div class="rounded-lg bg-white p-6 shadow">
				<h2 class="text-xl font-semibold text-gray-900">Preview Import</h2>
				<p class="mt-1 text-gray-600">Account: {parseResult.accountName}</p>

				<div class="mt-4 grid grid-cols-3 gap-4 text-center">
					<div class="rounded bg-blue-50 p-4">
						<p class="text-2xl font-bold text-blue-600">{parseResult.totalOrders}</p>
						<p class="text-sm text-gray-600">Orders</p>
					</div>
					<div class="rounded bg-gray-50 p-4">
						<p class="text-2xl font-bold text-gray-600">{parseResult.skippedRows}</p>
						<p class="text-sm text-gray-600">Skipped</p>
					</div>
					<div class="rounded bg-purple-50 p-4">
						<p class="text-2xl font-bold text-purple-600">{parseResult.assetSummaries.length}</p>
						<p class="text-sm text-gray-600">Assets</p>
					</div>
				</div>

				{#if parseResult.errors.length > 0}
					<div class="mt-4 rounded bg-yellow-50 p-4">
						<p class="font-medium text-yellow-800">Warnings ({parseResult.errors.length})</p>
						<ul class="mt-2 text-sm text-yellow-700">
							{#each parseResult.errors.slice(0, 5) as err}
								<li>Line {err.line}: {err.message}</li>
							{/each}
							{#if parseResult.errors.length > 5}
								<li>... and {parseResult.errors.length - 5} more</li>
							{/if}
						</ul>
					</div>
				{/if}

				<h3 class="mt-6 font-semibold text-gray-900">Assets to Import</h3>
				<div class="mt-2 max-h-96 overflow-y-auto">
					<table class="w-full text-sm">
						<thead class="bg-gray-50 sticky top-0">
							<tr>
								<th class="px-3 py-2 text-left">ISIN</th>
								<th class="px-3 py-2 text-left">Ticker</th>
								<th class="px-3 py-2 text-left">Name</th>
								<th class="px-3 py-2 text-right">Qty</th>
								<th class="px-3 py-2 text-right">Orders</th>
							</tr>
						</thead>
						<tbody class="divide-y">
							{#each parseResult.assetSummaries as asset}
								<tr>
									<td class="px-3 py-2 font-mono text-xs">{asset.isin}</td>
									<td class="px-3 py-2">{asset.ticker}</td>
									<td class="px-3 py-2 truncate max-w-xs">{asset.name}</td>
									<td class="px-3 py-2 text-right">{asset.totalQuantity}</td>
									<td class="px-3 py-2 text-right text-gray-500">
										{asset.buyCount}B / {asset.sellCount}S
									</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>

				<div class="mt-6 flex gap-4">
					<button
						onclick={confirmImport}
						disabled={importing}
						class="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:opacity-50"
					>
						{importing ? 'Importing...' : 'Confirm Import'}
					</button>
					<button onclick={reset} class="rounded bg-gray-200 px-4 py-2 text-gray-700 hover:bg-gray-300">
						Cancel
					</button>
				</div>
			</div>
		{:else}
			<!-- File Upload -->
			<div class="rounded-lg bg-white p-6 shadow">
				<label class="block">
					<span class="text-gray-700">Select Directa CSV file</span>
					<input
						bind:this={fileInput}
						type="file"
						accept=".csv"
						onchange={handleFileSelect}
						class="mt-2 block w-full text-sm text-gray-500
							file:mr-4 file:rounded file:border-0
							file:bg-blue-50 file:px-4 file:py-2
							file:text-sm file:font-semibold file:text-blue-700
							hover:file:bg-blue-100"
					/>
				</label>

				<div class="mt-6 rounded bg-gray-50 p-4 text-sm text-gray-600">
					<p class="font-medium">Expected CSV format (Directa export):</p>
					<ul class="mt-2 list-inside list-disc space-y-1">
						<li>First 10 lines are header/metadata</li>
						<li>12 columns: Date, Value Date, Type, Ticker, ISIN, Protocol, Description, Qty, EUR, Currency Amt, Currency, Reference</li>
						<li>Only Buy and Sell transactions will be imported</li>
					</ul>
				</div>
			</div>
		{/if}
	</main>
</div>
