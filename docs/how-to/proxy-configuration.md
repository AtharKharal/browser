---
title: Proxy Configuration — Lightpanda Browser
description: Configure HTTP proxies, bearer token authentication, and proxy routing in Lightpanda.
tags:
  - How-To
  - Proxy
  - Network
---

# Proxy Configuration

Lightpanda routes all outbound HTTP requests through a single configurable proxy. Proxy support is implemented in `browser/HttpClient.zig` via libcurl and applies to everything: HTML fetches, XHR calls, Fetch API requests, and external script loading.

---

## Basic Proxy Configuration

Pass the proxy URL via `--http-proxy`. Basic authentication (username:password) can be embedded in the URL:

```bash
./lightpanda serve \
  --host 127.0.0.1 \
  --port 9222 \
  --http-proxy http://user:password@proxy.example.com:8080
```

Or without authentication:
```bash
./lightpanda fetch \
  --http-proxy http://proxy.example.com:3128 \
  https://target.example.com
```

---

## Bearer Token Proxy Authentication

For proxies that require `Proxy-Authorization: Bearer <token>` instead of embedded credentials:

```bash
./lightpanda serve \
  --http-proxy http://proxy.example.com:8080 \
  --proxy-bearer-token your-secret-token
```

This injects the `Proxy-Authorization: Bearer your-secret-token` header into all requests. The token value is sourced from `Config.zig:Common.proxy_bearer_token`.

---

## Scope

The proxy applies globally to **all** HTTP requests made by the browser instance:

- Initial HTML page loads
- External JavaScript (both `<script src>` and dynamic imports)
- XHR (`XMLHttpRequest`)
- Fetch API calls
- CSS and linked resources

There is no per-domain or per-resource proxy routing. If selective routing is required, place a proxy relay upstream that selectively forwards traffic.

---

## Proxy with Docker

```yaml title="docker-compose.yml"
services:
  lightpanda:
    image: lightpanda/browser:nightly
    command: >
      serve
        --host 0.0.0.0
        --port 9222
        --http-proxy http://squid-proxy:3128
    ports:
      - "9222:9222"
```

---

## TLS Verification with Proxies

Proxies that perform SSL inspection may present their own certificate for HTTPS endpoints. If the proxy CA is not trusted by the system, connections will fail TLS verification.

!!! danger "Do Not Disable TLS Verification in Production"
    If you are certain the proxy CA is controlled by your organization and the risk is understood, you may pass `--insecure-disable-tls-host-verification`. This flag disables host verification for **all** connections, not just the proxy.

In production, install your organization's CA certificate into the system trust store of the container/host instead.
