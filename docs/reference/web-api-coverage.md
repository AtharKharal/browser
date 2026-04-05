---
title: Web API Coverage — Lightpanda Browser
description: Current implementation status of Web APIs in Lightpanda Browser.
tags:
  - Reference
  - Web APIs
  - Compatibility
---

# Web API Coverage

Lightpanda implements a growing subset of the Web APIs required for JavaScript-driven page evaluation. This reference documents the current coverage state.

!!! abstract "Coverage Philosophy"
    Lightpanda prioritizes APIs that affect page evaluation outcomes for automation and scraping workloads. Graphical, media, and accessibility APIs that serve human users but have no impact on automation results are deprioritized.

---

## DOM APIs

| API | Status | Notes |
|---|---|---|
| `document.querySelector` / `querySelectorAll` | Stable | Full CSS selector support |
| `document.getElementById` | Stable | |
| `document.createElement` | Stable | |
| `document.createTextNode` | Stable | |
| `element.innerHTML` / `outerHTML` | Stable | |
| `element.textContent` | Stable | |
| `element.getAttribute` / `setAttribute` | Stable | |
| `element.addEventListener` / `removeEventListener` | Stable | |
| `element.classList` | Stable | |
| `element.style` | Partial | Read/write CSS properties |
| `element.getBoundingClientRect` | Partial | Returns zero for all dimensions (no layout engine) |
| `element.scrollIntoView` | Stub | |
| `MutationObserver` | Stable | |
| `IntersectionObserver` | Partial | |
| `ResizeObserver` | Partial | |

---

## Network APIs

| API | Status | Notes |
|---|---|---|
| `XMLHttpRequest` | Stable | Full async support |
| `fetch()` | Stable | Including `Request`, `Response`, `Headers` |
| `WebSocket` | Partial | In development |
| `EventSource` | Partial | In development |
| `AbortController` / `AbortSignal` | Stable | |

---

## Timers and Events

| API | Status |
|---|---|
| `setTimeout` / `clearTimeout` | Stable |
| `setInterval` / `clearInterval` | Stable |
| `requestAnimationFrame` | Stub (fires immediately) |
| `Promise` | Stable (V8 native) |
| `async` / `await` | Stable (V8 native) |
| `queueMicrotask` | Stable |

---

## Storage

| API | Status |
|---|---|
| `document.cookie` | Stable |
| `localStorage` | Stable |
| `sessionStorage` | Stable |
| `IndexedDB` | Not implemented |
| `Cache API` | Not implemented |

---

## HTML Form APIs

| API | Status |
|---|---|
| `HTMLInputElement.value` | Stable |
| `HTMLSelectElement.value` | Stable |
| `HTMLFormElement.submit()` | Stable |
| `FormData` | Stable |
| `File` / `FileList` | Partial |
| `FileReader` | Not implemented |

---

## CORS

| Status | Notes |
|---|---|
| Not yet implemented | Tracked in [issue #2015](https://github.com/lightpanda-io/browser/issues/2015). Currently all cross-origin requests are allowed. Deploy behind a proxy to enforce CORS semantics. |

!!! danger "CORS Not Enforced"
    Cross-Origin Resource Sharing (CORS) is not currently enforced by Lightpanda. Any page script can make cross-origin requests regardless of server-side CORS headers. This is a known limitation and is tracked upstream.
