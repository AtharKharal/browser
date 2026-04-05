---
name: model-validator
description: Extract schema-aligned data models and payloads into documentation tables with zero ambiguity.
---

# Practitioner: The Model Validator

## Goal
Extract schema-aligned data models and payloads into documentation tables with zero ambiguity.

## Logic Overview
1. **Schema Extraction**: Parse JSON Schema, TypeScript interfaces, or Postman body samples.
2. **Tabular Formatting**: Build descriptive tables with:
    - **Property**: Key name.
    - **Type**: Data type (e.g., `string`, `integer`, `boolean`, `object`, `array`).
    - **Requirement**: `Required` vs `Optional`.
    - **Description**: Verifiable documentation of the property.
    - **Example**: Realistic sample value.

## Apparatus Mapping
- **Script**: `./scripts/extract_schemas.py`
- **Input**: Source file (JSON Schema, TS, or Postman body).

## Templates
- **Primary**: `./resources/model_table.md.j2`

## Standards Compliance
- Must use consistent casing for property names.
- Must flag deprecated properties with warning alerts.
