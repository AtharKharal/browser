---
title: CLI Reference — Lightpanda Browser
description: Complete reference for all Lightpanda CLI commands, flags, and defaults. Sourced from Config.zig.
tags:
  - Reference
  - CLI
---

# CLI Reference

All CLI flags documented here are extracted directly from `src/Config.zig`. Defaults are drawn from the `Common`, `Serve`, `Fetch`, and `Mcp` struct definitions.

---

## Command Overview

```
lightpanda <command> [flags]
```

| Command | Purpose |
|---|---|
| `fetch <URL>` | Evaluate a URL and dump output to stdout. No persistence. |
| `serve` | Start a persistent WebSocket CDP server for Puppeteer/Playwright. |
| `mcp` | Start a Model Context Protocol server over stdio. |
| `version` | Print the build version. |
| `help` | Display usage information. |

---

## `fetch` Command

Single-shot page evaluation. Downloads the URL, executes JavaScript, and emits the rendered output.

```bash
lightpanda fetch [flags] <URL>
```

### Flags — Output Control

| Flag | Type | Default | Description |
|---|---|---|---|
| `--dump <format>` | string | none | Dump document to stdout. Values: `html`, `markdown`, `semantic_tree`, `semantic_tree_text`. Omitting prints nothing. |
| `--strip-mode <list>` | string | none | Comma-separated groups to strip from dump. Values: `js`, `ui`, `css`, `full`. |
| `--with-base` | bool | `false` | Inject a `<base>` tag into the dump reflecting the original URL. |
| `--with-frames` | bool | `false` | Include iframe content in the dump output. |

### Flags — Wait Conditions

!!! info "Wait flag precedence"
    `--wait-ms` overrides all other wait parameters when specified. `--wait-until` is checked first, then `--wait-selector`/`--wait-script` after that condition is met.

| Flag | Type | Default | Description |
|---|---|---|---|
| `--wait-ms <ms>` | uint32 | `5000` | Fixed wait duration in milliseconds after page load. Overrides all other wait flags. |
| `--wait-until <event>` | string | `done` | Wait for a lifecycle event. One of: `load`, `domcontentloaded`, `networkidle`, `done`. |
| `--wait-selector <css>` | string | none | Wait for an element matching this CSS selector to appear in the DOM. |
| `--wait-script <js>` | string | none | Wait until this JavaScript expression returns truthy. |
| `--wait-script-file <path>` | string | none | Same as `--wait-script` but reads from a file. |

### Dump Format Reference

| Value | Output |
|---|---|
| `html` | Rendered HTML (post-JavaScript evaluation) |
| `markdown` | Simplified Markdown-compatible text extraction |
| `semantic_tree` | Structured semantic DOM representation |
| `semantic_tree_text` | Text-only semantic tree (no markup) |

---

## `serve` Command

Starts the persistent Chrome DevTools Protocol WebSocket server.

```bash
lightpanda serve [flags]
```

### Flags — Network

| Flag | Type | Default | Description |
|---|---|---|---|
| `--host <addr>` | string | `127.0.0.1` | IP address to bind the CDP server. Use `0.0.0.0` to accept external connections. |
| `--port <n>` | uint16 | `9222` | TCP port for the CDP WebSocket listener. |
| `--advertise-host <addr>` | string | value of `--host` | Advertised hostname in `/json/version` response. Useful when binding to `0.0.0.0` but need to advertise a specific address. |

### Flags — Connections

| Flag | Type | Default | Description |
|---|---|---|---|
| `--timeout <secs>` | uint31 | `10` | Inactivity timeout in seconds before disconnecting a CDP session. Maximum: `604800` (1 week). |
| `--cdp-max-connections <n>` | uint16 | `16` | Maximum simultaneous active CDP sessions. |
| `--cdp-max-pending-connections <n>` | uint16 | `128` | Backlog depth for the TCP accept queue. |

---

## `mcp` Command

Starts the Model Context Protocol server over standard input/output.

```bash
lightpanda mcp [flags]
```

| Flag | Type | Default | Description |
|---|---|---|---|
| `--version <ver>` | string | `2024-11-05` | Override the MCP protocol version. Valid: `2024-11-05`, `2025-03-26`, `2025-06-18`, `2025-11-25`. |
| `--cdp-port <n>` | uint16 | none | Optionally start a bundled CDP server on this port alongside the MCP stdio server. |

---

## Common Flags

These flags apply to `fetch`, `serve`, and `mcp` modes.

### Network Behavior

| Flag | Type | Default | Description |
|---|---|---|---|
| `--http-proxy <url>` | string | none | HTTP proxy for all outbound requests. Format: `http://user:pass@host:port`. |
| `--proxy-bearer-token <token>` | string | none | Proxy-Authorization Bearer token, sent as `Proxy-Authorization: Bearer <token>`. |
| `--http-max-concurrent <n>` | uint8 | `10` | Maximum simultaneous HTTP requests across the browser instance. |
| `--http-max-host-open <n>` | uint8 | `4` | Maximum open connections to any single host:port. |
| `--http-connect-timeout <ms>` | uint31 | `0` | TCP connection establishment timeout in milliseconds. `0` = no limit. |
| `--http-timeout <ms>` | uint31 | `10000` | Total transfer timeout in milliseconds per request. `0` = no limit. |
| `--http-max-response-size <n>` | usize | none | Maximum acceptable response body size in bytes. Applies to all request types (scripts, XHR, Fetch, HTML). |
| `--http-cache-dir <path>` | string | none | File system path to use as an HTTP response cache. Disabling caching degrades performance for repeat visits. |
| `--obey-robots` | bool | `false` | Fetch and enforce `robots.txt` for all navigated domains. |
| `--insecure-disable-tls-host-verification` | bool | `false` | Bypass TLS host certificate verification. High-risk flag. Should only be used in controlled test environments. |

### User Agent

| Flag | Type | Default | Description |
|---|---|---|---|
| `--user-agent-suffix <text>` | string | none | Text appended to the default `Lightpanda/1.0` User-Agent. Useful for rate-limit negotiation or bot authentication. |

### Web Bot Authentication (Ed25519)

These flags enable structured HTTP request signing for bot-permissive server frameworks.

| Flag | Type | Default | Description |
|---|---|---|---|
| `--web-bot-auth-key-file <path>` | string | none | Path to an Ed25519 private key PEM file. |
| `--web-bot-auth-keyid <id>` | string | none | The JWK thumbprint of the public key. |
| `--web-bot-auth-domain <domain>` | string | none | Your domain (e.g., `your-company.com`). |

All three `--web-bot-auth-*` flags must be provided together or none will take effect.

### Logging

| Flag | Values | Default (Debug) | Default (Release) |
|---|---|---|---|
| `--log-level` | `debug`, `info`, `warn`, `error`, `fatal` | `info` | `warn` |
| `--log-format` | `pretty`, `logfmt` | `pretty` | `logfmt` |
| `--log-filter-scopes` | comma-separated scope names | none | none |

#### Log Scopes

Scopes allow filtering verbose log categories in production. Common values:
`http`, `unknown_prop`, `event`, `app`, `mcp`, `browser`, `telemetry`.

Example — suppress XHR noise while retaining app-level logs:
```bash
lightpanda serve --log-filter-scopes http
```

---

## Environment Variables

| Variable | Effect |
|---|---|
| `LIGHTPANDA_DISABLE_TELEMETRY=true` | Disables all telemetry collection and transmission. |

---

## Exit Codes

| Code | Meaning |
|---|---|
| `0` | Success |
| `1` | Fatal error — check stderr for details |
