---
title: Disable Telemetry — Lightpanda Browser
description: How to disable Lightpanda's usage telemetry for privacy-compliant and air-gapped deployments.
tags:
  - How-To
  - Privacy
  - Operations
---

# Disable Telemetry

Lightpanda collects anonymous usage telemetry by default. This guide explains how to disable it.

---

## Environment Variable

Set `LIGHTPANDA_DISABLE_TELEMETRY=true` in the environment before launching any Lightpanda process:

=== "Linux / macOS (shell)"
    ```bash
    export LIGHTPANDA_DISABLE_TELEMETRY=true
    ./lightpanda serve --host 127.0.0.1 --port 9222
    ```

=== "Shell Profile (persistent)"
    Add to `~/.bashrc`, `~/.zshrc`, or `/etc/environment`:
    ```bash
    echo 'export LIGHTPANDA_DISABLE_TELEMETRY=true' >> ~/.bashrc
    source ~/.bashrc
    ```

=== "Docker"
    ```bash
    docker run -d \
      -e LIGHTPANDA_DISABLE_TELEMETRY=true \
      --name lightpanda \
      -p 9222:9222 \
      lightpanda/browser:nightly
    ```

=== "Docker Compose"
    ```yaml
    services:
      lightpanda:
        image: lightpanda/browser:nightly
        environment:
          - LIGHTPANDA_DISABLE_TELEMETRY=true
    ```

=== "Systemd Service"
    ```ini
    [Service]
    Environment=LIGHTPANDA_DISABLE_TELEMETRY=true
    ExecStart=/usr/local/bin/lightpanda serve --host 127.0.0.1 --port 9222
    ```

---

## Verification

When telemetry is disabled, the startup log will show:

```
INFO  telemetry : telemetry status . . . . . . .  [+0ms]
      disabled = true
```

When telemetry is enabled (default), it shows:
```
INFO  telemetry : telemetry status . . . . . . .  [+0ms]
      disabled = false
```

---

## What Is Collected

When enabled, Lightpanda transmits anonymous usage data to inform development prioritization. No page content, URLs navigated, DOM data, or personally identifiable information is transmitted.

For the complete data collection specification, see [lightpanda.io/privacy-policy](https://lightpanda.io/privacy-policy).
