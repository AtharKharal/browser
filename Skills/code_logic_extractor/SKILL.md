---
name: code-logic-extractor
description: >
  Extracts structural logic, variables, functions, and architecture constraints from a codebase
  via AST parsing. IMPORTANT: The primary script only supports Python (.py) codebases.
  For non-Python repos (Zig, Go, Rust, Java, etc.), follow the Manual Structural Analysis
  fallback protocol documented in Section 5.
---

# Code Logic Extractor

## 1. Goal

Transform undocumented or legacy repositories into verifiable documentation by mapping source code
to architecture, invariants, contracts, and operational runbooks. All claims must be traceable to
actual source artifacts.

---

## 2. Language Support Matrix

| Language | Extraction Method | Script |
|---|---|---|
| Python | AST parse (automated) | `scripts/extract_logic.py` |
| JavaScript / TypeScript | AST parse (automated) | `scripts/extract_logic.py` |
| Zig | Manual Structural Analysis | See Section 5 |
| Go | Manual Structural Analysis | See Section 5 |
| Rust | Manual Structural Analysis | See Section 5 |
| Java / Kotlin | Manual Structural Analysis | See Section 5 |

> **Failure Mode:** Invoking `extract_logic.py` on a non-Python codebase returns an empty JSON map
> (`functions: [], classes: []`). This is a silent failure — the script exits 0. Always check the
> output before proceeding. If the map is empty and the repo is not Python, switch to Manual
> Structural Analysis immediately.

---

## 3. Automated Extraction (Python Repos)

```powershell
.\venv\Scripts\python.exe Skills/code_logic_extractor/scripts/extract_logic.py `
  --repo-path <TARGET_DIRECTORY> `
  --output .tmp/logic_map.json
```

**Verify the output is not empty:**
```powershell
Get-Content .tmp/logic_map.json | ConvertFrom-Json | Select-Object -ExpandProperty functions | Measure-Object | Select-Object Count
```

If `Count` is 0 and the repo is not Python, proceed to Section 5.

---

## 4. Artifacts Generated from Logic Map

From the extracted JSON, produce these documentation pillars:

| Artifact | Content | Extraction Rule |
|---|---|---|
| `ARCHITECTURE.md` | Mermaid.js diagram of modules and dependencies | `dependencies` field in JSON |
| `LOGIC_INVARIANTS.md` | Table of business rules from constants/conditionals | Flagged variables and enum patterns |
| `CONTRACTS.md` | Strict input/output definitions per function | Function signatures from JSON |
| `OPERATIONS.md` | Happy path flow + known failure signatures | Error handling blocks |

Every statement must cite a source file and line number. If logic is ambiguous (e.g., deeply
nested conditionals), flag it as **Logic Debt** rather than inferring intent.

---

## 5. Manual Structural Analysis (Non-Python Repos)

When AST extraction is unavailable, apply this deterministic manual protocol:

### Step 1 — Directory Mapping
```powershell
ls -Recurse <REPO_ROOT>/src | Select-Object FullName, Length | Sort-Object Length -Descending
```
- List all source files sorted by size (largest = most important modules)
- Note the directory structure (flat vs. layered, domain grouping vs. technical grouping)

### Step 2 — Entry Point Identification
For each language, find the entry point:
- **Zig:** `src/main.zig` — look for `pub fn main()`
- **Go:** `main.go` or `cmd/` directory
- **Rust:** `src/main.rs` or `src/lib.rs`

Read the entry point to identify:
- Mode dispatch pattern (e.g., `switch (mode)`)
- Primary subsystems initialized
- Configuration struct and CLI parsing location

### Step 3 — Configuration Surface
Find the config/args parsing file (frequently the largest non-core file):
- Read it fully to extract all CLI flags, defaults, and struct fields
- This is the authoritative source for the Operations reference

### Step 4 — Module Dependency Graph
For each major module:
- Read the first 80 lines to identify imports and struct definitions
- Map `A → B` relationships (what calls what)
- Document in Mermaid `graph TD` format

### Step 5 — Key Struct Extraction
Identify the core data structures:
- For Zig: read `.zig` files, look for `pub const` and `pub const <Name> = struct`
- For Go: look for `type <Name> struct` declarations
- For Rust: look for `pub struct` and `impl` blocks

Document all public fields with their types and default values.

### Step 6 — Produce Logic Map JSON Equivalent
Create a hand-crafted `.tmp/logic_map.json` in the same schema as `extract_logic.py` output,
so downstream artifact generation templates can consume it without modification.

---

## 6. Determinism Constraints

1. Every statement in final documentation must cite a file path and line number.
2. If logic is ambiguous, flag as **Logic Debt** — do not infer intent.
3. Validate README setup instructions by actually running them, not by reading them.
4. For non-Python repos: explicitly state in the generated `ARCHITECTURE.md` that analysis
   was performed via manual structural inspection rather than automated AST parsing.
