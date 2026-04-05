---
name: integrity-guard
description: Enforce documentation consistency across the repository through automated auditing and validation.
---

# Practitioner: The Integrity Guard

## Goal
Enforce documentation consistency across the repository through automated auditing and validation.

## Logic Overview
1. **Change Detection**: Scan for modifications to OpenAPI specs, Postman collections, or source code (e.g., `octokit/rest.js`).
2. **Impact Analysis**: Identify affected documentation fragments using the [Navigational Determinism](file:///e:/Computing/github-docs-swarm-3/agents.md#navigational-determinism) rule.
3. **Audit Execution**: Compare the current documentation state with the new source artifact.
4. **Patch Proposal**: If discrepancies exist, propose minimal, targeted patches using `patch_docs.py`.

## Apparatus Mapping
- **Script**: `./scripts/audit_docs.py`
- **Input**: Source Changeset (diff or updated file).

## Standards Compliance
- Must fail with clear error messages if validation fails.
- Must preserve version history during patching.
