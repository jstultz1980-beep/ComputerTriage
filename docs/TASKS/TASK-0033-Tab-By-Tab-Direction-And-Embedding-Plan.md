# TASK-0033 - Tab-By-Tab Direction And Embedding Plan

## Status
Active

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
- [ ] Directory tab direction is explicitly decided.
- [ ] The recommendation answers whether network information belongs on Directory or should stay on Network/Infrastructure.
- [ ] Recommendations avoid duplicating Network and Infrastructure tabs.
- [ ] Embedded-tool candidates are listed and prioritized.
- [ ] Each embedded recommendation states why embedded UI is better than a launcher.
- [ ] The roadmap recommends whether the Quick Target Checks embedded output pattern should become the shared base for other pages.
- [ ] Follow-on Codex implementation tasks are created if changes are accepted.
