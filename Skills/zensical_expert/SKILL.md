---
name: zensical-expert
description: >
  Expert-level skill for Zensical — the modern static site generator.
  Provides deterministic scaffolding of Zensical portals via Python-driven Jinja2 templates.
  Encodes all known TOML syntax constraints, broken extension combinations, and deployment patterns
  discovered through production use. Eliminates config parse failures and port conflicts.
---

# Zensical Expert Skill

## 1. Goal

Provide zero-error scaffolding for Zensical documentation portals using verified Jinja2 templates and
battle-tested configuration patterns. Eliminates `TOMLDecodeError`, `ValueError`, and extension
compatibility failures.

---

## 2. Script Execution

**Never manually write `zensical.toml` from scratch.** Use the pre-built Jinja2 template system:

```powershell
.\venv\Scripts\python.exe Skills/zensical_expert/scripts/generate_config.py `
  --template <TEMPLATE_TYPE> [OPTIONS]
```

**Valid `<TEMPLATE_TYPE>` values:**

| Template | Use Case |
|---|---|
| `sme_portal` | Internal organizational knowledge bases |
| `client` | External-facing product documentation |
| `migration` | 1:1 MkDocs Material visual parity |
| `minimal` | Barebones instance, no extras |
| `offline` | Zipped distribution without CDN dependencies |

**Available overrides (all optional):**
- `--site_name`, `--site_url`, `--site_description`, `--site_author`
- `--copyright_year`, `--copyright_holder`
- `--repo_url`, `--repo_name` (client template)
- `--analytics_property` (client template)

**Example:**
```powershell
.\venv\Scripts\python.exe Skills/zensical_expert/scripts/generate_config.py `
  --template client `
  --site_name "My Product Docs" `
  --site_url "https://myorg.github.io/project/"
```

---

## 3. CRITICAL — Known TOML Syntax Constraints

### 3.1 Inline Tables MUST be Single-Line

TOML does not permit newlines inside inline table literals. The `palette` array is the most common
failure point. **WRONG** (will cause `TOMLDecodeError`):

```toml
# BREAKS THE PARSER — multiline inline table
palette = [
    {scheme = "default", primary = "blue",
     toggle = {icon = "material/brightness-7", name = "Dark"}}
]
```

**CORRECT** (each entry on one line):
```toml
palette = [
    {scheme = "default", primary = "deep purple", accent = "cyan", toggle = {icon = "material/brightness-7", name = "Switch to dark"}},
    {scheme = "slate", primary = "deep purple", accent = "cyan", toggle = {icon = "material/brightness-4", name = "Switch to light"}}
]
```

> **Action:** The `client_facing.toml.j2` template has been patched to use single-line palette
> entries. If a new template is created, always verify this constraint.

### 3.2 Incompatible Extensions (Cause `ValueError`)

The following `pymdownx` extensions are **not supported** by Zensical v0.0.31 and cause
`ValueError: not enough values to unpack` when present in the config:

- `[project.markdown_extensions.pymdownx.inlinehilite]`
- `[project.markdown_extensions.pymdownx.keys]`

Do not include these. Use `pymdownx.highlight` with `anchor_linenums = true` for line highlighting.

### 3.3 Extensions Required for Grids and Cards

For `<div class="grid cards">` content to render, you **must** include:
```toml
[project.markdown_extensions.attr_list]
[project.markdown_extensions.md_in_html]
```

`md_in_html` is often absent from templates but is required for card grids.

---

## 4. Navigation Syntax

The `nav` array uses TOML inline table syntax. Nested entries use arrays within values:

```toml
nav = [
  {"Home" = "index.md"},
  {"Tutorials" = [
      {"Quick Start" = "tutorials/getting-started.md"},
      {"Puppeteer" = "tutorials/puppeteer.md"}
  ]},
  {"Reference" = [
      {"API" = "reference/api.md"}
  ]}
]
```

All nav keys and values must be on deterministic single lines. The nav is intentionally placed
**inside** the `[project]` section (before `[project.theme]`).

---

## 5. Serving and Building

```powershell
# Serve with hot reload (default port 8000)
.\venv\Scripts\zensical.exe serve

# Serve on alternate port (if 8000 is in use — port conflict is common)
.\venv\Scripts\zensical.exe serve --dev-addr localhost:8001

# Production build (outputs to site/)
.\venv\Scripts\zensical.exe build
```

**Port conflict detection:** If `serve` fails with `os error 10048`, port 8000 is in use by a
previous process. Use `--dev-addr localhost:8001` immediately without further investigation.

---

## 6. Recommended Full Configuration (Production)

The canonical production `zensical.toml` for a client-facing portal:

```toml
[project]
site_name        = "Project Documentation"
site_url         = "https://org.github.io/project/"
site_description = "Developer documentation for Project."
site_author      = "Org"
copyright        = "&copy; 2025 Org"
repo_url         = "https://github.com/org/project"
repo_name        = "org/project"
edit_uri          = "edit/main/docs/"

nav = [
  {"Home" = "index.md"}
]

[project.theme]
variant = "modern"
features = [
    "navigation.instant",
    "navigation.instant.prefetch",
    "navigation.instant.progress",
    "navigation.tracking",
    "navigation.tabs",
    "navigation.tabs.sticky",
    "navigation.sections",
    "navigation.indexes",
    "navigation.path",
    "navigation.top",
    "toc.follow",
    "search.suggest",
    "search.highlight",
    "content.code.copy",
    "content.tabs.link",
]
palette = [
    {scheme = "slate", primary = "deep purple", accent = "cyan", toggle = {icon = "material/brightness-4", name = "Switch to light mode"}},
    {scheme = "default", primary = "deep purple", accent = "cyan", toggle = {icon = "material/brightness-7", name = "Switch to dark mode"}}
]

[project.theme.font]
text = "Inter"
code = "JetBrains Mono"

[project.markdown_extensions.admonition]
[project.markdown_extensions.pymdownx.details]
[project.markdown_extensions.pymdownx.superfences]
[project.markdown_extensions.pymdownx.highlight]
  anchor_linenums = true
[project.markdown_extensions.pymdownx.tabbed]
  alternate_style = true
[project.markdown_extensions.pymdownx.tasklist]
  custom_checkbox = true
[project.markdown_extensions.attr_list]
[project.markdown_extensions.md_in_html]
[project.markdown_extensions.def_list]
[project.markdown_extensions.footnotes]
[project.markdown_extensions.tables]
[project.markdown_extensions.toc]
  permalink = true
[project.markdown_extensions.abbr]

[project.plugins.search]
[project.plugins.tags]
```

> **Note:** Do NOT add `[project.plugins.social]` unless the Social Cards plugin is correctly
> configured — it may fail in environments without the `cairosvg` package.

---

## 7. Diagnosing Config Errors

If `zensical serve` fails with a config error, apply this binary bisection protocol:

1. Replace `zensical.toml` with the minimal baseline (Section 6 without nav/palette/fonts).
2. Run `zensical serve`. If it works, the minimal baseline is valid.
3. Add back sections one at a time: nav → palette → font → markdown_extensions → plugins.
4. The section that causes failure on re-add is the culprit.
5. Most common culprits in order: `palette` (multiline), incompatible extensions, `plugins.social`.

---

## 8. Knowledge Assets

- `resources/authoring-snippets.md` — All Markdown syntax (admonitions, tabs, grids, diagrams)
- `resources/config-reference.md` — Comprehensive config field reference
- `resources/client_facing.toml.j2` — Primary production template (patched for single-line palette)
