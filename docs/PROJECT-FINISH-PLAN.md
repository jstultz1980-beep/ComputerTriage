# Project Finish Plan

## Current Read
The toolkit is near the end of its UI and workflow cleanup pass. The punch list is closed, GitHub and local `master` were synced after TASK-0070, and no implementation task is currently active.

The remaining work is not a large new product direction. It is a controlled finish-line sequence:

1. Make ARGUS real enough to trust.
2. Turn analysis outputs into useful reports.
3. Connect Collect, Analyze, Review, and Submit into one technician workflow.
4. Reduce remaining performance friction.
5. Package the tool in a way that is defensible around antivirus and EDR products.
6. Run release-candidate validation and document known limitations.

## What ARGUS Actually Is Today
ARGUS has a minimal foundation slice from TASK-0023:

- It validates required HEPHAESTUS artifacts.
- It reads evidence score, findings, timeline, and machine profile.
- It writes `ARGUS/input-validation.json`, `ARGUS/analysis-summary.json`, and `ARGUS/report.md`.
- It labels deterministic findings separately from ARGUS inference.

That is useful scaffolding, but it is not the finished ARGUS layer. The missing product-level work is:

- A clearer evidence map from available bundle files to ARGUS reasoning areas.
- Normalized loaders for evidence domains beyond the initial required artifacts.
- Event grouping and symptom clustering.
- Recommendation text that is structured, cited, and confidence-scored.
- A technician-facing report format that can survive escalation review.
- UI integration so ARGUS is part of the normal workflow rather than a console-only foundation command.

## Security And EDR Position
The project must not try to hide tools from antivirus or EDR products.

The acceptable direction is to reduce false positives and make the toolkit easier to trust:

- Prefer signed, reputable, portable utilities where possible.
- Track source URLs, publisher names, versions, hashes, and license notes.
- Separate high-friction tools from the default bundle when they are not needed for normal triage.
- Make risky or commonly flagged tools optional Add-Ons with clear provenance.
- Provide allowlisting documentation for managed environments.
- Avoid packing, encryption, obfuscation, hidden launchers, or behavior that looks like evasion.
- Keep tool execution user-visible and auditable.

## Release Definition
The first release candidate is ready when:

- Quick Dx, Triage, Analyze, Reports, Settings, and core maintenance workflows run without obvious UI breakage.
- HEPHAESTUS local analysis and ARGUS outputs are generated from a current bundle.
- Reports are readable enough for technician handoff or escalation.
- Tab switching first-render lag is measured and either improved or documented with acceptable limits.
- Embedded-tool provenance and EDR handling are documented.
- Deploy/update behavior preserves client data and excludes development files.
- Smoke, button-smoke, parser, triage, local-analysis, ARGUS, reporting, deployment/update, and package validation pass.
- Known limitations are written down instead of being tribal knowledge.

## Ordered Finish-Line Queue

### 1. TASK-0072 - ARGUS Product Definition And Evidence Map
Define the finished ARGUS behavior before adding more code.

Deliverables:
- ARGUS evidence-domain map.
- Input/output contract cleanup.
- Confidence, citation, and unsupported-inference rules.
- Decision on whether ADR-0003 needs status/text reconciliation.

### 2. TASK-0073 - ARGUS Evidence Normalization Implementation
Build the next ARGUS loaders and normalized analysis model.

Deliverables:
- Domain loaders for available HEPHAESTUS outputs.
- Normalized ARGUS intermediate model.
- Tests against existing and synthetic bundles.

### 3. TASK-0074 - ARGUS Event Grouping And Recommendation Engine
Turn normalized facts into coherent diagnostic groups and technician actions.

Deliverables:
- Symptom clusters.
- Root-cause candidates.
- Confidence-scored recommendations.
- Explicit citations back to deterministic findings and normalized evidence.

### 4. TASK-0075 - Reporting Finish Pass
Make report output useful outside the app.

Deliverables:
- Technician report.
- Escalation/AI handoff report.
- Executive or customer-safe summary if appropriate.
- Report file naming and bundle placement rules.

### 5. TASK-0076 - Analyze Workflow UI Integration
Connect collection, local analysis, ARGUS, and report review into the app.

Deliverables:
- Analyze page workflow.
- Latest analysis/report shortcuts.
- Clear status messages for missing/limited evidence.
- No console-only dependency for normal use.

### 6. TASK-0077 - First-Render Tab Performance Hardening
Measure and reduce remaining tab-switching lag.

Deliverables:
- Timing report for first render and repeat render.
- Heavy tab initialization deferral where appropriate.
- Acceptance threshold or documented limitation.

### 7. TASK-0078 - Embedded Tool Trust And EDR-Safe Distribution
Address antivirus/EDR friction without evasion.

Deliverables:
- Tool provenance manifest.
- Hash and publisher inventory.
- Optional Add-On/default-bundle split recommendations.
- Allowlisting/admin deployment guidance.
- Removal or quarantine plan for tools that are not worth the trust cost.

### 8. TASK-0079 - Release Packaging And Update Hardening
Validate the actual portable/deployed package behavior.

Deliverables:
- Fresh deployment validation.
- Update validation.
- Client-data preservation validation.
- Development-file exclusion validation.
- Version/build metadata and release artifact checklist.

### 9. TASK-0080 - Release Candidate Validation And Documentation
Run the final release-candidate gate.

Deliverables:
- Full validation matrix.
- Known limitations.
- User-facing quick-start/release notes.
- Final GitHub sync recommendation.

## Parking Lot
These are not immediate blockers unless they affect release validation:

- Product rename execution from Network Toolkit to RapidAssist or another final name.
- Deeper HEPHAESTUS rule coverage beyond what ARGUS/reporting needs for first release.
- Multi-computer or fleet analysis.
- Signed installer/MSIX packaging.
- Automated update channel.
