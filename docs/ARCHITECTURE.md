# Architecture

## Boundary
Computer Triage Toolkit is a single-computer diagnostic product.

## Current Repository Layout
```text
C:\computer_toolkit
|-- PROJECT.md
|-- README.md
|-- NetworkToolkit.vbs
|-- App
|-- Core
|   `-- Argus
`-- docs
```

## App
User interface, launcher, manifests, technician-facing workflows, existing
collectors, utilities, plugins, and portable application integration.

## Core
Core engines and reusable internal logic.

ARGUS is the analysis and explanation engine. The intended component name is
ARGUS. The current repository path is:

```text
Core/Argus
```

Future tasks may normalize casing if needed.

## Scripts
Operational scripts, collectors, utility actions, and support workflows
currently live inside `App/NetworkToolkit` until a task explicitly moves them.

## docs
Governance, design records, roadmap, tasks, handoff, reviews, and history.
