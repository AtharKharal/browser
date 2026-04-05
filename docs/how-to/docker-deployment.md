---
title: Docker Deployment — Lightpanda Browser
description: Running Lightpanda in Docker, including container configuration, networking, and production considerations.
tags:
  - How-To
  - Docker
  - Deployment
---

# Docker Deployment

Lightpanda provides official Docker images for Linux amd64 and arm64 from Docker Hub.

---

## Quick Start

```bash
docker run -d \
  --name lightpanda \
  -p 9222:9222 \
  lightpanda/browser:nightly
```

This starts Lightpanda in `serve` mode, binding the CDP WebSocket server to port 9222 on the container's network interface. Port `9222` is forwarded to the host.

---

## Available Images

| Tag | Description |
|---|---|
| `nightly` | Latest build from the `main` branch |
| Versioned tags | Stable releases (when available) |

Images are available for:
- `linux/amd64` (x86_64)
- `linux/arm64` (aarch64)

---

## Configuration via Environment Variables

Lightpanda accepts all CLI flags as arguments. Pass them in the Docker `command` field:

```bash
docker run -d \
  --name lightpanda \
  -p 9222:9222 \
  lightpanda/browser:nightly \
  serve \
    --host 0.0.0.0 \
    --port 9222 \
    --log-format logfmt \
    --log-level warn \
    --cdp-max-connections 32 \
    --timeout 60
```

To disable telemetry inside the container:
```bash
docker run -d \
  -e LIGHTPANDA_DISABLE_TELEMETRY=true \
  --name lightpanda \
  -p 9222:9222 \
  lightpanda/browser:nightly
```

---

## Docker Compose

```yaml title="docker-compose.yml"
services:
  lightpanda:
    image: lightpanda/browser:nightly
    command: >
      serve
        --host 0.0.0.0
        --port 9222
        --log-format logfmt
        --log-level warn
        --cdp-max-connections 32
        --timeout 60
    ports:
      - "9222:9222"
    environment:
      - LIGHTPANDA_DISABLE_TELEMETRY=true
    restart: unless-stopped
    # Optional: limit container resources
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
```

---

## Connecting from the Host

When Lightpanda binds to `0.0.0.0` inside the container and port `9222` is exposed, connect from the Docker host using `ws://localhost:9222`:

```javascript
const browser = await puppeteer.connect({
  browserWSEndpoint: "ws://localhost:9222",
});
```

For container-to-container communication within a Docker Compose network, use the service name:
```javascript
const browser = await puppeteer.connect({
  browserWSEndpoint: "ws://lightpanda:9222",
});
```

---

## Advertise Host

When binding to `0.0.0.0` but the `/json/version` endpoint needs to return a specific IP (for client auto-discovery), use `--advertise-host`:

```bash
docker run -d \
  --name lightpanda \
  -p 9222:9222 \
  lightpanda/browser:nightly \
  serve --host 0.0.0.0 --port 9222 --advertise-host 192.168.1.10
```

---

## Health Check

Lightpanda does not expose a dedicated health endpoint, but the `/json/version` HTTP endpoint serves as a reliable liveness probe:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:9222/json/version"]
  interval: 10s
  timeout: 5s
  retries: 3
  start_period: 5s
```
