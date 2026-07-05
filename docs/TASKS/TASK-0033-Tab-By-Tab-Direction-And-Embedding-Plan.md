# TASK-0033 - Tab-By-Tab Direction And Embedding Plan

## Status
Completed

## Owner
Codex

## Objective
Run the planned tab-by-tab analysis pass and define which tabs should remain launchers, which should become richer workflow pages, and which launch-only tools should become embedded experiences.

## Scope
- Review current Directory tab tools and adjacent Network/Infrastructure tools.
- Decide whether to add useful domain/network discovery information directly on the Directory tab.
- Decide whether network context belongs on Directory or whether Directory should stay focused on AD/domain identity.
- Inventory launch-only tools that would benefit from embedded UI.
- Compare existing embedded-output patterns, especially Quick Target Checks versus `Start-GUISafeScriptRunner`, and define one preferred technician-facing console/output pattern.
- Identify which tabs should use compact in-tab output panes and which should use full-tab overlays.
- Identify tools that should get their own tab versus live inside an existing tab.
- Identify which tools should remain launch buttons versus embedded tab experiences.
- Recommend candidate embedded tools or dedicated tabs.
- Produce focused Codex implementation tasks.

## Design Questions
- Should Directory show domain controller discovery, domain join state, secure channel state, DNS SRV records, site/subnet hints, GPO summary, or AD replication clues?
- Which of those belong on Directory versus Network/Infrastructure/Analyze?
- Which existing launch-only tools should become embedded forms?
- What information can be collected safely and quickly on a random workstation?
- Which tabs are overloaded, sparse, redundant, or confusing after the current cleanup pass?

## Out of Scope
- Application code changes.
- ARGUS implementation.
- Downloading tools.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [x] Directory tab direction is explicitly decided.
- [x] The recommendation answers whether network information belongs on Directory or should stay on Network/Infrastructure.
- [x] Recommendations avoid duplicating Network and Infrastructure tabs.
- [x] Embedded-tool candidates are listed and prioritized.
- [x] Each embedded recommendation states why embedded UI is better than a launcher.
- [x] The roadmap recommends whether the Quick Target Checks embedded output pattern should become the shared base for other pages.
- [x] Follow-on Codex implementation tasks are created if changes are accepted.

## Deliverables

- `docs\DESIGN\TAB-BY-TAB-EMBEDDING-PLAN.md`
- `TASK-0054-Directory-Domain-Status-Page`
- `TASK-0055-Shared-Embedded-Output-Pattern`
- `TASK-0056-Triage-Guided-Workflow-Polish`
- `TASK-0057-WiFi-And-Windows-Status-Polish`
- `TASK-0058-Settings-And-Control-Polish`
- `TASK-0059-Documentation-Build-Counter-Audit`

## Validation

- Reviewed the current GUI tab builders and registered tab list.
- Reviewed the current tool catalog placement by tab, section, and run mode.
- Re-read `punch_list.txt` before completion.
- Confirmed the next step must be an audit gate because Documentation reaches `10 / 10`.
