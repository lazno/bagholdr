/**
 * Global Rate Limiter for Yahoo Finance API
 *
 * Yahoo Finance has an unofficial rate limit of ~2000 requests/hour.
 * This rate limiter ensures we stay well under that by:
 * - Enforcing a minimum delay between requests (default 2 seconds)
 * - Queuing requests and processing them sequentially
 * - Being a singleton so ALL Yahoo requests go through it
 *
 * With 2 second delay: 30 requests/min = 1800/hour (safe margin)
 */

import { YAHOO_MIN_REQUEST_DELAY_MS } from '../config';

// Enable verbose logging for debugging (set to false in production)
const VERBOSE_LOGGING = true;

function formatDuration(ms: number): string {
	if (ms < 1000) return `${ms}ms`;
	return `${(ms / 1000).toFixed(1)}s`;
}

function log(message: string) {
	if (VERBOSE_LOGGING) {
		console.log(`[YahooRateLimiter] ${message}`);
	}
}

interface QueuedRequest<T> {
	execute: () => Promise<T>;
	resolve: (value: T) => void;
	reject: (error: unknown) => void;
	enqueuedAt: number;
}

class YahooRateLimiter {
	private queue: QueuedRequest<unknown>[] = [];
	private isProcessing = false;
	private lastRequestTime = 0;
	private readonly minDelayMs: number;
	private requestCount = 0;

	constructor(minDelayMs: number = YAHOO_MIN_REQUEST_DELAY_MS) {
		this.minDelayMs = minDelayMs;
		log(`Initialized with ${formatDuration(minDelayMs)} minimum delay between requests`);
	}

	/**
	 * Enqueue a request to be executed with rate limiting.
	 * Returns a promise that resolves when the request completes.
	 */
	async enqueue<T>(execute: () => Promise<T>): Promise<T> {
		return new Promise<T>((resolve, reject) => {
			this.queue.push({
				execute,
				resolve: resolve as (value: unknown) => void,
				reject,
				enqueuedAt: Date.now()
			});
			log(`Request enqueued (queue length: ${this.queue.length})`);
			this.processQueue();
		});
	}

	private async processQueue(): Promise<void> {
		if (this.isProcessing || this.queue.length === 0) {
			return;
		}

		this.isProcessing = true;

		while (this.queue.length > 0) {
			const request = this.queue.shift();
			if (!request) break;

			// Calculate delay needed
			const now = Date.now();
			const timeSinceLastRequest = now - this.lastRequestTime;
			const delayNeeded = Math.max(0, this.minDelayMs - timeSinceLastRequest);
			const queueWaitTime = now - request.enqueuedAt;

			if (delayNeeded > 0) {
				log(`Waiting ${formatDuration(delayNeeded)} before next request...`);
				await this.sleep(delayNeeded);
			}

			// Execute the request
			const requestStartTime = Date.now();
			try {
				this.lastRequestTime = Date.now();
				this.requestCount++;
				const result = await request.execute();
				const requestDuration = Date.now() - requestStartTime;
				log(`Request #${this.requestCount} completed in ${formatDuration(requestDuration)} (queued for ${formatDuration(queueWaitTime)})`);
				request.resolve(result);
			} catch (error) {
				const requestDuration = Date.now() - requestStartTime;
				log(`Request #${this.requestCount} failed after ${formatDuration(requestDuration)}: ${error instanceof Error ? error.message : 'Unknown error'}`);
				request.reject(error);
			}
		}

		this.isProcessing = false;
	}

	private sleep(ms: number): Promise<void> {
		return new Promise((resolve) => setTimeout(resolve, ms));
	}

	/**
	 * Get current queue length (useful for monitoring)
	 */
	get queueLength(): number {
		return this.queue.length;
	}

	/**
	 * Check if currently processing requests
	 */
	get isActive(): boolean {
		return this.isProcessing;
	}

	/**
	 * Get total number of requests processed
	 */
	get totalRequests(): number {
		return this.requestCount;
	}
}

// Singleton instance - all Yahoo requests go through this
export const yahooRateLimiter = new YahooRateLimiter();
