---
title: Build from Source — Lightpanda Browser
description: Compile the Lightpanda Browser binary from the Zig source code, including V8 snapshot embedding.
tags:
  - How-To
  - Build
  - Zig
---

# Build from Source

Building Lightpanda from source gives you control over build mode, snapshot embedding, and custom compilation options. This guide covers the prerequisites, build commands, and the V8 snapshot optimization path.

!!! abstract "Prerequisites"
    - Zig `0.15.2` (exact version required — see note)
    - Rust (required for `html5ever`)
    - Git

!!! warning "Exact Zig Version Required"
    Lightpanda requires **Zig 0.15.2 exactly**. Other Zig versions, including newer releases, are not guaranteed to compile the project. Use the [official Zig download page](https://ziglang.org/download/) to obtain the correct version.

---

## 1. Install System Dependencies

=== "Debian / Ubuntu"
    ```bash
    sudo apt install xz-utils ca-certificates \
        pkg-config libglib2.0-dev \
        clang make curl git
    # Rust is required for html5ever
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source "$HOME/.cargo/env"
    ```

=== "macOS"
    ```bash
    brew install cmake
    # Rust is required for html5ever
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    ```

=== "Nix"
    The project ships a `flake.nix` that provides all dependencies in a reproducible shell:
    ```bash
    nix develop
    # All tools are now available in your PATH
    ```

---

## 2. Clone the Repository

```bash
git clone git@github.com:lightpanda-io/browser.git
cd browser
```

---

## 3. Build

### Release Build (Recommended)

The `make build` target compiles in `ReleaseFast` mode. It first generates the V8 snapshot, then builds the main binary with that snapshot embedded:

```bash
make build
```

What this runs internally:
```bash
# Step 1: Generate V8 snapshot
zig build -Doptimize=ReleaseFast snapshot_creator -- src/snapshot.bin

# Step 2: Build with snapshot embedded
zig build -Doptimize=ReleaseFast -Dsnapshot_path=../../snapshot.bin
```

The binary is output to `zig-out/bin/lightpanda`.

### Debug Build

For development, use the debug build which enables the GPA (General Purpose Allocator) with leak detection:

```bash
make build-dev
# Equivalent to:
zig build
```

Debug builds are slower but catch memory leaks at process exit and include additional assertions.

---

## 4. V8 Snapshot (Advanced)

By default, Lightpanda generates the V8 JavaScript engine snapshot on every startup. This involves compiling the V8 runtime APIs and takes ~100ms. For production binaries, embed the pre-generated snapshot to achieve ~10ms startup:

```bash
# Generate the snapshot binary
zig build snapshot_creator -- src/snapshot.bin

# Build the binary with the snapshot file embedded
zig build -Doptimize=ReleaseFast -Dsnapshot_path=../../snapshot.bin
```

Run the optimized binary:
```bash
./zig-out/bin/lightpanda serve
```

---

## 5. Running After Build

```bash
# Direct Zig execution (no install step)
zig build run

# Or run the compiled binary
./zig-out/bin/lightpanda serve --host 127.0.0.1 --port 9222
```

---

## 6. Build Targets Summary

| Make Target | Description |
|---|---|
| `make build` | Release build with embedded V8 snapshot |
| `make build-dev` | Debug build with GPA leak detection |
| `make run` | Release build + start server |
| `make run-debug` | Debug build + start server |
| `make test` | Run unit test suite |
| `make end2end` | Run end-to-end tests (requires `../demo` clone) |

---

## 7. Running Tests

### Unit Tests

```bash
make test
# Equivalent to:
zig build test -freference-trace
```

To filter to a specific test:
```bash
make test F="server"
```

### End-to-End Tests

Requires the `demo` repository to be cloned adjacent to `browser`:
```bash
git clone git@github.com:lightpanda-io/demo.git ../demo
cd ../demo && npm install
make end2end
```

### Web Platform Tests (WPT)

Lightpanda is tested against the standardized [Web Platform Tests](https://web-platform-tests.org/). Running WPT requires additional setup:

```bash
# Clone the Lightpanda WPT fork
git clone -b fork --depth=1 git@github.com:lightpanda-io/wpt.git

cd wpt

# Install custom domain entries
./wpt make-hosts-file | sudo tee -a /etc/hosts

# Generate the manifest
./wpt manifest
```

Then start the WPT HTTP server in one terminal, Lightpanda in another, and the Go test runner:
```bash
# Terminal 1: WPT HTTP server
cd wpt && ./wpt serve

# Terminal 2: Lightpanda
zig build run -- --insecure-disable-tls-host-verification

# Terminal 3: Go test runner
cd ../demo/wptrunner && go run .
```

Run a single WPT test:
```bash
go run . Node-childNodes.html
```

!!! warning "WPT Suite Duration"
    Running the full WPT suite takes a long time. For test suite runs, build in `ReleaseFast` mode to reduce test execution time:
    ```bash
    zig build -Doptimize=ReleaseFast run
    ```
