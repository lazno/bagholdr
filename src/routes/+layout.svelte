<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import '../app.css';
	import favicon from '$lib/assets/favicon.svg';
	import { serverEvents } from '$lib/stores/serverEvents';

	let { children } = $props();

	onMount(() => {
		// Connect to server events WebSocket
		serverEvents.connect();
	});

	onDestroy(() => {
		serverEvents.disconnect();
	});
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<title>FinancePal</title>
</svelte:head>

{@render children()}
