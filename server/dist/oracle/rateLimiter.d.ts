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
declare class YahooRateLimiter {
    private queue;
    private isProcessing;
    private lastRequestTime;
    private readonly minDelayMs;
    private requestCount;
    constructor(minDelayMs?: number);
    /**
     * Enqueue a request to be executed with rate limiting.
     * Returns a promise that resolves when the request completes.
     */
    enqueue<T>(execute: () => Promise<T>): Promise<T>;
    private processQueue;
    private sleep;
    /**
     * Get current queue length (useful for monitoring)
     */
    get queueLength(): number;
    /**
     * Check if currently processing requests
     */
    get isActive(): boolean;
    /**
     * Get total number of requests processed
     */
    get totalRequests(): number;
}
export declare const yahooRateLimiter: YahooRateLimiter;
export {};
