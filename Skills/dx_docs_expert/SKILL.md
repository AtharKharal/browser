---
name: dx-documentation-orchestrator
description: >
  Systematic framework for transforming any technical repository — API collection, Zig/Go/Rust
  codebase, or mixed-source — into a high-impact Developer Experience (DX) documentation portal.
  Uses the Diátaxis information architecture across Tutorials, How-To Guides, Reference, and
  Explanation quadrants. Produces substantive documentation that surpasses the source README
  in scope, depth, and practical value.
---

# DX Documentation Orchestrator

## 1. Goal

Produce documentation that a developer can act on immediately, not documentation that restates
what a README already says. Every page must add information or perspective not in the source
code's existing comments or README.

---

## 2. Diátaxis Quadrant Mapping

Apply the four-quadrant model to all content:

| Quadrant | Orientation | Examples |
|---|---|---|
| **Tutorials** | Learning-oriented | "Quick Start", "Your first Puppeteer script", "Hello World" |
| **How-To Guides** | Problem-oriented | "Build from Source", "Configure a Proxy", "Disable Telemetry" |
| **Reference** | Information-oriented | CLI flags, CDP domains, Web API coverage, architecture diagrams |
| **Explanation** | Understanding-oriented | Design philosophy, memory model, why Zig was chosen |

---

## 3. Minimum Content Standards

Each page must contain **at least three** of the following:

- [ ] One or more Mermaid.js diagrams (sequence, flowchart, state machine, component map)
- [ ] Tabbed content blocks (`===`) for OS/runtime alternatives
- [ ] At least two admonition blocks (`!!!`) — use `tip`, `warning`, `info`, `danger`, `abstract`
- [ ] Annotated code blocks with `# (1)!` callouts
- [ ] A data table with 3+ columns
- [ ] Collapsible troubleshooting blocks (`???`)
- [ ] Cross-links to related pages using relative paths

Pages that contain only prose paragraphs without diagrams, tables, or structured content are
considered incomplete and must be revised.

---

## 4. Diagram Requirements

For each category of documentation, the following diagrams are mandatory:

| Page Type | Required Diagrams |
|---|---|
| Architecture Reference | Component map (all subsystems), at least one data flow diagram |
| Protocol Reference | Sequence diagram for happy-path flow |
| Tutorial | Sequence diagram showing what happens internally during the tutorial |
| CLI Reference | Flowchart for mode dispatch |
| Explanation pages | Conceptual comparison diagram or state machine |

Always use `mermaid` fenced code blocks. Zensical renders Mermaid.js natively via `pymdownx.superfences`.

---

## 5. Admonition Usage Guide

Use admonitions with intent, not decoration:

| Type | When to Use |
|---|---|
| `!!! abstract` | Prerequisites checklists at page top |
| `!!! tip` | Non-obvious efficiency gain or best practice |
| `!!! info` | Contextual clarification that isn't critical |
| `!!! warning` | Compatibility risk, behavioral difference, known limitation |
| `!!! danger` | Security risk, data loss risk, irreversible operation |
| `!!! failure` or `??? failure` | Specific error diagnosis — use collapsible for troubleshooting |

Do not use `!!! note` without a meaningful title. Empty or boilerplate admonitions degrade trust.

---

## 6. Content Depth Benchmarks

The final documentation must demonstrably surpass the repository's README in:

| Dimension | README Baseline | Documentation Target |
|---|---|---|
| Installation | 3–5 commands | Tabbed by OS/platform, with verification steps |
| Configuration | List of flags | Full table with types, defaults, and interaction effects |
| Architecture | Brief paragraph | Mermaid component map + subsystem descriptions |
| Error handling | Mentioned in passing | Dedicated collapsible troubleshooting section per failure mode |
| Integration | Single example | Multiple patterns (basic, concurrent, high-throughput, edge cases) |

---

## 7. Source Fidelity Rules

All documented claims must be verifiable against the codebase:

- CLI flags → read the config/args parsing source file
- Default values → read the struct definitions, not the README
- Error messages → read the error handling code paths
- Performance claims → link to official benchmark methodology

If a value cannot be verified from source, mark it explicitly as "Not verified — check upstream".
Never invent defaults, endpoints, or behavior from training knowledge alone.

---

## 8. Navigation Structure Template

For a standard software library/tool documentation portal:

```toml
nav = [
  {"Home" = "index.md"},
  {"Tutorials" = [
      {"Quick Start" = "tutorials/getting-started.md"},
      {"<Framework> Integration" = "tutorials/<framework>-walkthrough.md"}
  ]},
  {"How-To Guides" = [
      {"Build from Source" = "how-to/build-from-source.md"},
      {"Docker Deployment" = "how-to/docker-deployment.md"},
      {"<Key Operation>" = "how-to/<operation>.md"}
  ]},
  {"Reference" = [
      {"Architecture" = "reference/architecture.md"},
      {"CLI Reference" = "reference/cli-reference.md"},
      {"API/Protocol" = "reference/api-protocol.md"},
      {"Operations" = "reference/operations.md"},
      {"Performance" = "reference/performance.md"}
  ]},
  {"Explanation" = [
      {"Design Philosophy" = "explanation/design-philosophy.md"},
      {"<Core Concept>" = "explanation/<concept>.md"}
  ]}
]
```

Minimum page count for a credible technical documentation portal: **14 pages**.

---

## 9. Landing Page Requirements

The `index.md` must:

- Use `hide: [navigation, toc]` front matter for a full-width layout
- Open with a `<div class="grid cards">` block showcasing 4–6 key capabilities
- Include a `===` quick start tab block (Linux / macOS / Docker minimum)
- Include a compatibility/status table
- Close with CTA buttons: `[Get Started](path){ .md-button .md-button--primary }` and `[Reference](path){ .md-button }`
- Contain at least one Mermaid diagram

---

## 10. Self-Verification Checklist

Before marking documentation complete, verify:

- [ ] All nav entries in `zensical.toml` map to existing `.md` files
- [ ] All internal links use relative paths and resolve correctly
- [ ] `zensical build` exits 0 with no errors
- [ ] Every page has at least 3 structural elements beyond prose (diagrams, tables, admonitions, tabs)
- [ ] No page merely restates the README — all pages add net-new information
- [ ] CLI flags and defaults are verified against source code, not assumed