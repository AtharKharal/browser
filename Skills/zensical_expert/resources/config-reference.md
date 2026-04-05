# Zensical Configuration Reference

Full reference for `zensical.toml` settings and theme features.

## Table of Contents

1. [Project Settings](#1-project-settings)
2. [Theme Settings](#2-theme-settings)
3. [Navigation Features](#3-navigation-features)
4. [Search Settings](#4-search-settings)
5. [Markdown Extensions](#5-markdown-extensions)
6. [Analytics](#6-analytics)
7. [Tags](#7-tags)
8. [Social Cards](#8-social-cards)
9. [Versioning](#9-versioning)
10. [Offline Usage](#10-offline-usage)
11. [Colors and Fonts](#11-colors-and-fonts)
12. [Repository Integration](#12-repository-integration)
13. [Footer](#13-footer)
14. [Comment System](#14-comment-system)

---

## 1. Project Settings

```toml
[project]
site_name        = "My Site"           # REQUIRED
site_url         = "https://example.com"  # Required for instant nav, social cards, sitemap
site_description = "Short description for SEO"
site_author      = "Author Name"
copyright        = "&copy; 2025 Author Name"
docs_dir         = "docs"             # Default: "docs" (cannot be ".")
site_dir         = "site"             # Default: "site"
use_directory_urls = true             # Default: true; set false for offline/zip distribution
dev_addr         = "localhost:8000"   # Default dev server address

[project.extra]
key = "value"                         # Arbitrary key-value pairs for templates
```

---

## 2. Theme Settings

```toml
[project.theme]
variant  = "modern"    # "modern" (default) or "classic" (Material for MkDocs look)
features = [
    # See Navigation Features section below for full list
]
```

**Variant guidance:**
- `modern`: Fresh design; recommended for new projects.
- `classic`: Exact Material for MkDocs appearance. Use when migrating or when client expects MkDocs look.

---

## 3. Navigation Features

Declare as strings inside `features = [...]` under `[project.theme]`.

### Instant Navigation (SPA behavior)

```toml
"navigation.instant"           # XHR navigation, no full page reload (requires site_url)
"navigation.instant.prefetch"  # Prefetch on hover (experimental)
"navigation.instant.progress"  # Progress bar for slow connections (shows after 400ms)
```

### Instant Previews

```toml
# Enable via markdown extension config (see section 5)
# Link syntax: [Link text](#){ data-preview }
```

### Sidebar and Structure

```toml
"navigation.tracking"    # URL updates to active anchor in address bar
"navigation.tabs"        # Top-level sections as tabs (viewport > 1220px)
"navigation.tabs.sticky" # Tabs lock below header during scroll (use with navigation.tabs)
"navigation.sections"    # Top-level sections as groups in sidebar (viewport > 1220px)
"navigation.expand"      # All subsections expanded by default (INCOMPATIBLE with navigation.prune)
"navigation.path"        # Breadcrumb nav above page title
"navigation.prune"       # Reduce HTML size 33%+ by rendering only visible nav (INCOMPATIBLE with navigation.expand)
"navigation.indexes"     # Section index pages (INCOMPATIBLE with toc.integrate)
"navigation.top"         # Back-to-top button on scroll-up
```

### Table of Contents

```toml
"toc.follow"             # Sidebar auto-scrolls to active anchor
"toc.integrate"          # TOC rendered in left nav sidebar (INCOMPATIBLE with navigation.indexes)
```

### Explicit Navigation Structure (in [project])

```toml
[project]
nav = [
  {"Home"    = "index.md"},
  {"Section" = [
      "section/index.md",
      {"Page 1" = "section/page-1.md"},
      {"Page 2" = "section/page-2.md"},
  ]},
  {"External" = "https://example.com"}
]
```

### Per-Page Navigation Control (front matter)

```yaml
---
hide:
  - navigation   # Hide left sidebar
  - toc          # Hide right TOC
  - path         # Hide breadcrumb
---
```

---

## 4. Search Settings

```toml
"search.suggest"    # Autocomplete suggestions
"search.highlight"  # Highlight search terms on result pages
"search.share"      # Share search button (deep link to query)
```

---

## 5. Markdown Extensions

Extensions must be explicitly declared. TOML syntax:

```toml
# Admonitions (callouts)
[project.markdown_extensions.admonition]
[project.markdown_extensions.pymdownx.details]       # collapsible blocks (??? syntax)
[project.markdown_extensions.pymdownx.superfences]   # fenced code blocks, nested content

# Code blocks
[project.markdown_extensions.pymdownx.highlight]
  anchor_linenums = true
[project.markdown_extensions.pymdownx.inlinehilite]

# Content tabs
[project.markdown_extensions.pymdownx.tabbed]
  alternate_style = true

# Snippets (reusable content)
[project.markdown_extensions.pymdownx.snippets]

# Task lists
[project.markdown_extensions.pymdownx.tasklist]
  custom_checkbox = true

# Emoji
[project.markdown_extensions.pymdownx.emoji]
  emoji_index     = "material"
  emoji_generator = "material"

# Keys (keyboard shortcut rendering)
[project.markdown_extensions.pymdownx.keys]

# Math (KaTeX/MathJax)
[project.markdown_extensions.pymdownx.arithmatex]
  generic = true

# Attribute lists (add HTML attributes to Markdown elements)
[project.markdown_extensions.attr_list]

# Definition lists
[project.markdown_extensions.def_list]

# Footnotes
[project.markdown_extensions.footnotes]

# Tables
[project.markdown_extensions.tables]

# Table of Contents
[project.markdown_extensions.toc]
  permalink = true

# Abbreviations
[project.markdown_extensions.abbr]

# mkdocstrings (API documentation from docstrings)
[project.plugins.mkdocstrings]
```

### Instant Previews Extension

```toml
[project.markdown_extensions.zensical.extensions.preview]
configurations = [
    { targets.include = ["section/*", "reference.md"] }
]
```

---

## 6. Analytics

```toml
[project.theme.analytics]
provider = "google"
property = "G-XXXXXXXXXX"
feedback.title   = "Was this page helpful?"
feedback.ratings = [
    {icon = "material/emoticon-happy-outline", name = "This page was helpful", data = 1, note = "Thanks for your feedback!"},
    {icon = "material/emoticon-sad-outline",   name = "This page could be improved", data = 0, note = "Thanks! Help us improve this page."}
]
```

---

## 7. Tags

```toml
[project.plugins.tags]
```

Front matter usage:
```yaml
---
tags:
  - AI
  - API Reference
---
```

---

## 8. Social Cards

```toml
[project.plugins.social]
# Generates OG/Twitter cards automatically
# Requires site_url to be set
```

---

## 9. Versioning

```toml
[project.plugins.mike]
# Enables multiple doc versions (requires mike tool)
```

---

## 10. Offline Usage

```toml
[project.plugins.offline]
enabled = true
# Automatically sets use_directory_urls = false
```

---

## 11. Colors and Fonts

```toml
[project.theme]
palette = [
    {scheme = "default", primary = "indigo",  accent = "indigo",  toggle = {icon = "material/brightness-7", name = "Switch to dark mode"}},
    {scheme = "slate",   primary = "indigo",  accent = "indigo",  toggle = {icon = "material/brightness-4", name = "Switch to light mode"}}
]

[project.theme.font]
text = "Roboto"
code = "Roboto Mono"
```

Valid primary/accent colors: `red`, `pink`, `purple`, `deep purple`, `indigo`, `blue`, `light blue`, `cyan`, `teal`, `green`, `light green`, `lime`, `yellow`, `amber`, `orange`, `deep orange`, `brown`, `grey`, `blue grey`, `black`, `white`.

---

## 12. Repository Integration

```toml
[project]
repo_url  = "https://github.com/org/repo"
repo_name = "org/repo"
edit_uri   = "edit/main/docs/"
```

---

## 13. Footer

```toml
[project.theme]
social = [
    {icon = "fontawesome/brands/github",   link = "https://github.com/org"},
    {icon = "fontawesome/brands/linkedin", link = "https://linkedin.com/in/user"}
]
```

Navigation links in footer (front matter per page):
```yaml
---
links:
  - text: Related page
    link: related.md
---
```

---

## 14. Comment System

Zensical supports Giscus (GitHub Discussions-based):

```toml
[project.theme.comments]
provider = "giscus"
# Additional giscus configuration via extra.* keys
```