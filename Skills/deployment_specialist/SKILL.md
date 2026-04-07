---
name: deployment-specialist
description: >
  Automates build and deployment of Zensical/MkDocs documentation to GitHub Pages.
  Implements the Privacy-Partitioned Deployment pattern to prevent proprietary local files
  (agents.md, Skills/, .env) from being committed to public repositories.
  Includes fork-creation fallback for repos without write access.
---

# Deployment Specialist

## 1. Goal

Deploy the built static documentation site to GitHub Pages with zero leakage of local proprietary
files and minimal manual intervention.

---

## 2. Privacy-Partitioned Deployment (REQUIRED)

This is the canonical deployment pattern. It MUST be used for all GitHub Pages deployments.

**Principle:** Initialize a Git repository exclusively inside the build output directory (`site/`).
This ensures the parent directory's files (`agents.md`, `Skills/`, `.env`, etc.) are physically
unreachable by the Git tracking scope.

**Never run `git init` or `git add` from the project root directory.**

### Step-by-Step Protocol

```powershell
# Step 1: Build the static site
.\venv\Scripts\zensical.exe build
# Or for MkDocs: .\venv\Scripts\mkdocs.exe build

# Step 2: Pre-commit audit — verify site/ contains ONLY static assets
ls site/ -Recurse | Select-Object FullName
# Expected: Only .html, .css, .js, .json, .xml, .png files
# ABORT if agents.md, Skills/, or .env appear in the listing

# Step 3: Add .nojekyll (required — prevents GitHub from running Jekyll on the output)
New-Item -ItemType File -Path "site/.nojekyll" -Force

# Step 4: Initialize an isolated Git repo INSIDE site/
Set-Location site/
git init -b gh-pages
git remote add origin git@github.com:<ORG>/<REPO>.git

# Step 5: Commit and push
git add .
git commit -m "docs: deploy documentation via Zensical"
git push origin gh-pages --force
```

---

## 3. Permission Model and Fallback

### 3.1 Direct Push (When You Have Write Access)

If the authenticated GitHub user has `push` access to the target repository, the push in Step 5
succeeds directly. SSH auth can be verified with:
```bash
ssh -T git@github.com
# Expected: Hi <USERNAME>! You've successfully authenticated
```

SSH auth success does NOT guarantee write access. Auth success means the key is recognized;
authorization depends on repo membership.

### 3.2 Fork-Based Deployment (When Write Access Is Denied)

If `ERROR: Permission to <ORG>/<REPO>.git denied to <USER>` appears:

```bash
# Step 1: Create a fork using GitHub CLI
gh repo fork <ORG>/<REPO> --clone=false
# Example: gh repo fork lightpanda-io/browser --clone=false
# Output: https://github.com/<USER>/<REPO>

# Step 2: Update the remote inside site/
git remote set-url origin git@github.com:<USER>/<REPO>.git

# Step 3: Push to the fork
git push origin gh-pages --force
```

The documentation will be available at: `https://<USER>.github.io/<REPO>/`

### 3.3 Enabling GitHub Pages on the Fork

After pushing to `gh-pages`, GitHub Pages must be enabled if not already active:

```bash
gh api repos/<USER>/<REPO>/pages \
  --method POST \
  -f source[branch]=gh-pages \
  -f source[path]=/
```

If Pages is already enabled, this returns HTTP 409 — that is expected and harmless.

Check the current status and live URL:
```bash
gh api repos/<USER>/<REPO>/pages
# Returns: { "html_url": "https://user.github.io/repo/", "status": "building" }
```

---

## 4. The `.nojekyll` File

GitHub Pages runs Jekyll by default on any branch served as a Page. Jekyll ignores files and
directories beginning with `_` (underscore). Zensical/MkDocs Material outputs `_` prefixed
directories for assets. Without `.nojekyll`, the entire `assets/` folder is silently stripped
from the served site.

Always create `site/.nojekyll` before committing. The Privacy-Partitioned protocol (Section 2)
handles this automatically.

---

## 5. CI/CD Automation (GitHub Actions)

For automated deployments on every push to `main`, use the following workflow:

```yaml title=".github/workflows/deploy-docs.yml"
name: Deploy Documentation

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.x'

      - name: Install dependencies
        run: pip install zensical

      - name: Build site
        run: zensical build

      - name: Create .nojekyll
        run: touch site/.nojekyll

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./site
          publish_branch: gh-pages
```

The `peaceiris/actions-gh-pages` action handles the isolated commit to `gh-pages` without
exposing the source branch files.

---

## 6. Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `Permission denied to <repo>` | User lacks write access | Use fork-based deployment (Section 3.2) |
| `fatal: not a git repository` | `site/.git` was deleted by rebuild | Re-run from Step 4 of Section 2 |
| Static assets 404 on live site | `.nojekyll` missing | Add `.nojekyll` and force-push |
| Pages shows old content | GitHub Pages CDN cache | Wait 2–5 minutes; Pages takes time to rebuild |
| `ERROR: repository exists` on fork | Fork already created | Skip `gh repo fork`; proceed to `git remote set-url` |
