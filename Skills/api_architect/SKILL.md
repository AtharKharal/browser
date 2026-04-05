---
name: api-architect
description: Generate deterministic, high-fidelity API reference documentation from Postman collections or OpenAPI specifications.
---

# Practitioner: The API Architect

## Goal
Generate deterministic, high-fidelity API reference documentation from Postman collections or OpenAPI specifications.

## Logic Overview
1. **Source Mapping**: Parse the `item` list from a Postman collection.
2. **Tabbed Interface**: For each endpoint, generate a MkDocs Material [Content Tab](https://squidfunk.github.io/mkdocs-material/reference/content-tabs/) containing:
    - **Method & URL**: Clear identification of the resource.
    - **Description**: Verifiable intent of the endpoint.
    - **Parameters**: Structured tables with types, requirements, and descriptions.
    - **Request Example**: Code blocks for common languages (cURL, Python, JS).
    - **Response Example**: Schema-aligned JSON payloads.

## Apparatus Mapping
- **Script**: `./scripts/generate_api_ref.py`
- **Input**: Path to Postman Collection JSON.
- **Output**: Markdown files in `docs/api-reference/`.

## Templates
- **Primary**: `./resources/api_endpoint.md.j2`
- **Model**: `./resources/model_table.md.j2`

## Standards Compliance
- Must use GitHub-style alerts for critical notes.
- Must ensure all internal links resolve.
- Must follow the naming convention: `docs/api-reference/{folder_name}.md`.
