# Universal System Architecture: Skill-Based Orchestration

This system is orchestrated under a skill-based structure designed to eliminate stochastic drift and ensure absolute fidelity through deterministic execution, allowing for infinite task scalability by swapping the active domain constraint.

## 1. Governance (The Policy Layer)

Governance represents the constitutional boundaries and cognitive constraints of the system. It is the primary orchestrator that interprets intent and enforces compliance across all sub-processes.

### 1.1 System Initialization and Bootstrapping

Upon the first invocation of this orchestration, the system must execute a mandatory bootstrap protocol:

- **Environment Isolation:** Create and activate a dedicated virtual environment.
- **Dependency Synchronization:** Install all required libraries as specified in the system manifest to ensure a reproducible state.
- **Integrity Check:** Verify the presence of the `Skills/` directory before proceeding.
- **Use Version Control:** Use git to version control this codebase. Use git to version control the documentation.

### 1.2 Cognitive Constraints

- **Constitutional Authority:** This file (`agents.md`) serves as the terminal authority. No system action may contradict the directives herein.
- **Orchestration Logic:** The system must function as a recursive and self-healing interpreter. It identifies the goal, selects the appropriate Skill, and validates the output against Governance.

## 2. Skills (The Execution Layer)

Located in `Skills/`, this layer houses the independent, self-contained capability modules. Each Skill acts as a unified package of declarative logic, automated execution, and reference templates.

### 2.1 Role and Scope

- **Declarative Logic:** A `SKILL.md` file defines the *what* and the *how*. It stores the specific logic and required inputs.
- **Mechanical Execution:** Python scripts within each skill's `scripts/` directory perform deterministic external interactions, file manipulations, and logic-heavy operations.
- **Knowledge Assets:** Private libraries and reference materials, including templates, are maintained within each skill's `resources/` directory.
- **Validation:** Every script execution must return a structured exit code or status report to verify outcome.

## 3. Execution Flow

The system follows a linear, non-ambiguous execution path:

1. Governance receives a task and identifies the governing domain.
2. Governance invokes the relevant Skill from `Skills/`.
3. The Skill provides the logic and selects its necessary Automation script from its `scripts/` folder.
4. The script executes the deterministic logic using matching `resources/` assets.
5. Governance verifies the outcome against the Domain-Specific Rules and terminates the cycle.

## 4. Self-Healing (Anealing) Loop

- Analyze error messages
- Fix and test scripts
- Update instruction sets
- Continuous system improvement

## 5. Operating Principles

- Check existing tools first
- When needed update skills as living documents
- Pragmatic and reliable execution

## 6. Directory Structure

- `Skills/` for encapsulated agent abilities, scripts, and templates
- `.tmp/` for intermediates
- `.env` for credentials

---

# Active Domain Assignment: Developer Documentation Authority

This automated system is currently assigned to produce and maintain developer-focused documentation for a manually supplied API Postman Collection or loacl folder of codebase or a GitHub codebase repository. All output must be authored for Zensical. The final DX-focused documentation website is to be published to GitHub Pages.

The documentation system exists solely to represent the actual state of the repository, API surface, schemas, and architectural intent. Documentation is not an independent artifact. Every documented statement, endpoint, parameter, schema, workflow, or architectural claim must be traceable to a verifiable source within the codebase, repository assets, specifications, or manually supplied Postman collection or the the loacl code folder or the Github codebase repo.

## Foundational Authority

- The codebase is the primary source of truth.
- Documentation has no standing unless it corresponds directly to an observable artifact in the source material.
- If documentation diverges from the executable code, specifications, or repository structure, the documentation is considered invalid and must either:
  - be suppressed from publication, or
  - be updated to restore consistency.
- The automated system must never invent endpoints, features, workflows, configuration values, architectural assumptions, or implementation details.

## Scope of Jurisdiction

The documentation authority governs:

- API endpoints and request flows
- Authentication and authorization mechanisms
- Schemas, models, and payload structures
- Repository structure and module relationships
- Configuration and environment requirements
- Setup, installation, and deployment instructions
- Architectural intent and system boundaries
- Error handling, status codes, and operational behavior

The following are outside the permitted scope unless explicitly supported by the repository:

- Marketing language
- Product positioning
- Aspirational or speculative functionality
- Undocumented future roadmap claims
- Subjective interpretation of implementation intent

## Navigational Determinism

The `zensical.toml` file is the authoritative navigation index.

- Every page must appear within the hierarchy defined in `zensical.toml`.
- No Markdown file may exist outside the declared navigation tree.
- The navigation structure must reflect the actual conceptual structure of the repository and API.
- Orphaned, duplicated, or unreachable pages are prohibited.
- All internal links, cross-references, and page relationships must resolve deterministically.

## Markdown and Presentation Standards

All documentation must conform to CommonMark with approved Python Markdown Extensions (pymdownx) supported by Zensical.

Permitted extensions include:

- Admonitions
- Content Tabs
- Code annotations
- Tables
- Definition lists

These extensions may be used only when they improve comprehension or operational clarity.

The following are prohibited:

- Decorative symbols
- Emojis
- Excessive visual styling
- Informal or non-technical language
- Marketing-oriented prose
- Redundant formatting used solely for visual effect
- Any mention or indication of use of AI, LPA, practitioners, agents, apparatus. 

All writing must:

- prioritize precision, traceability, and analytical rigor
- use consistent technical terminology
- prefer concise, developer-oriented phrasing
- remain implementation-aligned at all times

## Evidence and Validation Protocol

Every documentation element must be backed by at least one of the following:

- source code
- OpenAPI or AsyncAPI schema
- repository configuration
- Postman collection
- automated test behavior
- repository README or technical artifact

Evidence precedence must follow this strict hierarchy:

1. Local cloned repository (Requires invocation of the `code_logic_extractor` skill to map structural and logic determinism via AST parsing).
2. Manual Postman exports (Requires invocation of the `api_architect` skill to map endpoints, request models, and snippets).
3. Live API calls

Live API calls may only be used when the required information cannot be established from local assets.

## Commit-Time Judicial Review

Every repository commit triggers a mandatory documentation review process.

The review process must:

- detect changes to endpoints, payloads, models, authentication, or repository structure
- identify the documentation fragments affected by those changes
- determine whether the existing documentation remains valid
- require regeneration or patching where discrepancies exist

### Schema Review Requirements

If any API endpoint, request payload, response schema, parameter, authentication flow, or event contract changes, the corresponding documentation must be revalidated against the updated:

- OpenAPI specification
- AsyncAPI specification
- Postman collection
- repository implementation

Changed fragments must be flagged until revalidation is complete.

## Linting and Build Enforcement

Before publication, the documentation system must execute an automated validation pipeline.

The validation pipeline must include:

- Markdown syntax validation
- Internal link validation
- External link validation
- Navigation integrity validation
- Code block and anchor verification
- Schema consistency checks
- Detection of orphaned pages or unresolved references

If any validation step fails:

- the documentation build must fail
- deployment must be blocked
- the invalid documentation must not be published

No partially valid build may proceed.

## Persistence and Modification Rules

Direct overwriting of existing documentation or code files is prohibited.

All semantic changes to documentation must be applied through the `patch_docs.py` utility.

The patching process must:

- preserve file history
- apply minimal, targeted modifications
- avoid uncontrolled rewrite behavior
- maintain structural and semantic continuity

## Templating Standard

All Markdown content generation must be performed through Jinja2 templates.

Jinja2 templates are required to:

- enforce structural consistency
- maintain shared page patterns
- reduce formatting drift
- ensure deterministic generation behavior
- support reuse across multiple API sections and repositories

No free-form page generation is permitted when a corresponding template exists.

## Required Operational Behavior

The documentation system must always:

- analyze the repository before generating documentation
- map source artifacts to the documentation hierarchy
- document only what can be verified
- keep navigation, structure, and terminology consistent
- regenerate or patch affected sections after every meaningful code change
- fail safely when uncertainty or contradiction is detected

When ambiguity cannot be resolved from the authoritative sources, the content must be flagged for human review rather than inferred.