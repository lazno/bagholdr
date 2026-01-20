/**
 * Screenshot utility for visual inspection
 *
 * Usage:
 *   pnpm screenshot <path> [name]              # Svelte app (default)
 *   pnpm screenshot <path> [name] --flutter    # Flutter web on port 3001
 *   pnpm screenshot [name] --emulator          # Android emulator via adb
 *
 * Examples:
 *   pnpm screenshot /                          # Svelte: screenshots/svelte/home.png
 *   pnpm screenshot /portfolios/1 detail       # Svelte: screenshots/svelte/detail.png
 *   pnpm screenshot / home --flutter           # Flutter web: screenshots/flutter/home.png
 *   pnpm screenshot home --emulator            # Emulator: screenshots/emulator/home.png
 *
 * Note: --emulator captures whatever is currently displayed on the emulator screen.
 *       The <path> argument is ignored for emulator screenshots.
 */

import { chromium } from '@playwright/test';
import { execSync } from 'child_process';
import { existsSync, mkdirSync, writeFileSync } from 'fs';
import { homedir } from 'os';
import { join } from 'path';

// Android SDK paths
const ANDROID_HOME = process.env.ANDROID_HOME || join(homedir(), 'Library/Android/sdk');
const ADB_PATH = join(ANDROID_HOME, 'platform-tools/adb');

const SVELTE_URL = 'http://localhost:5173';
const FLUTTER_URL = 'http://localhost:3001';
const SVELTE_SCREENSHOT_DIR = './tests/screenshots/svelte';
const FLUTTER_SCREENSHOT_DIR = './tests/screenshots/flutter';
const EMULATOR_SCREENSHOT_DIR = './tests/screenshots/emulator';

async function takeWebScreenshot(baseUrl: string, path: string, outputDir: string, name: string, isFlutter: boolean = false) {
	const browser = await chromium.launch();
	const context = await browser.newContext({
		viewport: { width: 1280, height: 720 },
	});
	const page = await context.newPage();

	const url = `${baseUrl}${path}`;
	console.log(`Navigating to: ${url}`);

	// Flutter debug mode keeps hot reload connections open, so networkidle never fires
	// Use 'load' + wait for Flutter's main element
	if (isFlutter) {
		await page.goto(url, { waitUntil: 'load', timeout: 60000 });
		// Wait for Flutter to render - look for flt-glass-pane (Flutter's container)
		try {
			await page.waitForSelector('flt-glass-pane', { timeout: 30000 });
			// Additional delay for Flutter to finish rendering
			await page.waitForTimeout(2000);
		} catch {
			// Fallback: just wait if selector not found
			console.log('Warning: flt-glass-pane not found, using fallback delay');
			await page.waitForTimeout(15000);
		}
	} else {
		await page.goto(url, { waitUntil: 'networkidle' });
	}

	if (!existsSync(outputDir)) {
		mkdirSync(outputDir, { recursive: true });
	}

	const screenshotPath = `${outputDir}/${name}.png`;
	await page.screenshot({ path: screenshotPath, fullPage: true });

	console.log(`Screenshot saved: ${screenshotPath}`);
	await browser.close();
}

function takeEmulatorScreenshot(outputDir: string, name: string) {
	// Check if adb exists
	if (!existsSync(ADB_PATH)) {
		console.error(`Screenshot failed: adb not found at ${ADB_PATH}`);
		console.error('Set ANDROID_HOME environment variable or install Android SDK.');
		process.exit(1);
	}

	// Check if emulator is running
	try {
		const devices = execSync(`"${ADB_PATH}" devices`, { encoding: 'utf-8' });
		if (!devices.includes('emulator')) {
			console.error('Screenshot failed: No emulator running.');
			console.error('Start it with: ./native/scripts/start.sh --emulator');
			process.exit(1);
		}
	} catch {
		console.error('Screenshot failed: adb not working.');
		process.exit(1);
	}

	if (!existsSync(outputDir)) {
		mkdirSync(outputDir, { recursive: true });
	}

	const screenshotPath = `${outputDir}/${name}.png`;

	console.log('Capturing emulator screen...');

	try {
		// Capture screenshot from emulator using adb
		const screenshot = execSync(`"${ADB_PATH}" exec-out screencap -p`, {
			encoding: 'buffer',
			maxBuffer: 10 * 1024 * 1024, // 10MB buffer for image
		});

		writeFileSync(screenshotPath, screenshot);
		console.log(`Screenshot saved: ${screenshotPath}`);
	} catch (err) {
		console.error('Screenshot failed:', err);
		process.exit(1);
	}
}

async function main() {
	const args = process.argv.slice(2);
	const isFlutter = args.includes('--flutter');
	const isEmulator = args.includes('--emulator');
	const filteredArgs = args.filter((arg) => !arg.startsWith('--'));

	if (isFlutter && isEmulator) {
		console.error('Error: Cannot use both --flutter and --emulator');
		process.exit(1);
	}

	if (isEmulator) {
		// For emulator, first arg is just the name (no path navigation)
		const name = filteredArgs[0] || 'screen';
		takeEmulatorScreenshot(EMULATOR_SCREENSHOT_DIR, name);
	} else {
		// Web-based screenshot (Svelte or Flutter)
		const path = filteredArgs[0] || '/';
		const name = filteredArgs[1] || path.replace(/\//g, '-').replace(/^-/, '') || 'home';
		const baseUrl = process.env.BASE_URL || (isFlutter ? FLUTTER_URL : SVELTE_URL);
		const outputDir = isFlutter ? FLUTTER_SCREENSHOT_DIR : SVELTE_SCREENSHOT_DIR;

		try {
			await takeWebScreenshot(baseUrl, path, outputDir, name, isFlutter);
		} catch (err: unknown) {
			const error = err as Error;
			if (error.message?.includes('ERR_CONNECTION_REFUSED')) {
				if (isFlutter) {
					console.error(
						'Screenshot failed: Flutter web server not running.\n' +
							'Start it with: ./native/scripts/start.sh --web'
					);
				} else {
					console.error('Screenshot failed: Dev server not running. Start it with: pnpm dev');
				}
			} else {
				console.error('Screenshot failed:', error);
			}
			process.exit(1);
		}
	}
}

main();
