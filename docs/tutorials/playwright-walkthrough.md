---
title: Playwright Integration — Lightpanda Browser
description: Using Playwright with Lightpanda, including compatibility considerations and workarounds.
tags:
  - Tutorial
  - Playwright
  - CDP
---

# Playwright Integration

Playwright connects to Lightpanda through the CDP `connect` method. While functional for many common workflows, Playwright's dynamic strategy selection based on browser capabilities creates compatibility considerations that do not exist with Puppeteer.

!!! warning "Compatibility Advisory"
    Playwright uses an intermediate JavaScript layer that selects an execution strategy based on discovered browser features. When Lightpanda gains a new Web API, Playwright may switch to a different code path for the same script. New paths may invoke APIs not yet implemented. For deterministic production scraping, prefer Puppeteer. For testing workflows where Playwright's assertions are valuable, the guidance below applies.

---

## Connection Method

Playwright does not support `browserWSEndpoint` directly on `chromium.launch()`. Use `chromium.connectOverCDP()` instead:

```javascript title="playwright-connect.mjs"
import { chromium } from 'playwright-core';

// Connect to the running Lightpanda CDP server
const browser = await chromium.connectOverCDP('ws://127.0.0.1:9222');
const context = browser.contexts()[0];
const page = await context.newPage();

await page.goto('https://demo-browser.lightpanda.io/amiibo/');
console.log(await page.title());

await page.close();
await browser.close();
```

!!! info "playwright-core vs playwright"
    Use `playwright-core` to avoid downloading bundled browser binaries. Playwright core connects to CDP-compatible servers already providing the browser.

---

## Locator Patterns

Playwright's locator API provides resilient selectors and built-in retry logic. These work with Lightpanda's DOM implementation.

```javascript
// Text-based locator (preferred)
const heading = page.getByText('Product Catalog');
await heading.waitFor();

// Role-based locator (ARIA)
const button = page.getByRole('button', { name: 'Add to Cart' });
await button.click();

// CSS selector locator
const grid = page.locator('.product-grid');
const count = await grid.locator('.product-card').count();
console.log(`Found ${count} products`);
```

---

## Screenshot and State Capture

```javascript
// Full page screenshot
await page.screenshot({ path: 'page.png', fullPage: true });

// Clip a specific element
const card = page.locator('.product-card').first();
await card.screenshot({ path: 'card.png' });

// Capture page HTML after JS evaluation
const html = await page.content();
```

---

## Known Limitations with Lightpanda

| Feature | Status |
|---|---|
| Basic navigation and `waitForURL` | Supported |
| `page.fill()`, `page.click()` | Supported |
| `page.evaluate()` | Supported |
| Screenshots | Supported |
| Network interception (`page.route()`) | Supported via CDP fetch domain |
| Video recording | Not supported |
| PDF generation | Not supported |
| `page.pdf()` | Not supported |
| `expect()` assertion library | Supported (runs in Node context) |
| `page.accessibility.snapshot()` | Partial — AX tree is implemented |

---

## Diagnosing Playwright-Specific Failures

If a Playwright script fails on Lightpanda but works on Chrome, isolate the failing CDP command:

```javascript
const cdpSession = await page.context().newCDPSession(page);

// Directly issue CDP commands to diagnose and compare responses
const domContent = await cdpSession.send('DOM.getDocument', { depth: 1 });
console.log(JSON.stringify(domContent, null, 2));
```

This allows you to determine whether the CDP domain is unimplemented or whether the issue is in Playwright's JavaScript layer.
