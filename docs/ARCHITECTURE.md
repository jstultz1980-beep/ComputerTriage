# Architecture

## Boundary
Computer Triage Toolkit is a single-computer diagnostic product.

## Layout
```text
Computer_Toolkit
├── PROJECT.md
├── App
├── Core
│   ├── HEPHAESTUS
│   └── ARGUS
├── Scripts
├── docs
└── Output
```

## App
User interface, launcher, manifests, and technician-facing workflows.

## Core
Core engines and reusable internal logic.

ARGUS belongs in:
```text
Core/ARGUS
```

## Scripts
Operational scripts, collectors, utility actions, and support workflows.

## docs
Governance, design records, roadmap, tasks, handoff, and reviews.
