# Project Charter

## Mission
Build a portable Windows diagnostic toolkit that quickly collects, analyzes, and explains the health of a single computer.

## Prime Directive
The Computer Triage Toolkit exists to move a technician from evidence collection to an actionable diagnosis as quickly and accurately as possible.

The toolkit shall prioritize deterministic local analysis first, AI-assisted reasoning second, and raw evidence presentation last.

Every feature must reduce the time, effort, or uncertainty required to diagnose a single computer.

## Scope
The toolkit is focused on one computer at a time.

## Primary Components
- HEPHAESTUS: evidence collection engine
- ARGUS: analysis and explanation engine
- Reporting: technician-focused outputs

## Non-Goals
The toolkit is not intended to become:
- Whole-network discovery
- SIEM
- RMM
- Asset inventory
- Compliance platform
- AI Builder

## Success Criteria
- Technician can run the toolkit quickly.
- Toolkit collects useful evidence.
- ARGUS identifies priority findings.
- Reports explain findings with supporting evidence.
- Project state is traceable through tasks, handoffs, and commits.

## Governance Responsibilities
ChatGPT owns:
- Architecture
- Governance
- Audits
- Reviews
- ADRs
- Roadmaps
- Executive summaries
- Code review
- Handoff preparation
- Task creation

Codex owns:
- Repository implementation
- Refactoring
- Validation
- Build fixes
- Testing
- Commits
