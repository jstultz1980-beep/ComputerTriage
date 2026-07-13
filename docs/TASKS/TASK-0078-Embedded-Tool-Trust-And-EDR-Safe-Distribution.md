# TASK-0078 - Embedded Tool Trust And EDR Safe Distribution

## Status
Superseded

## Superseded By

`TASK-0093-External-Tool-Provenance-And-Lifecycle-Policy`

TASK-0093 completed the provenance, lifecycle, trust, licensing, EULA, privilege, EDR, and production-retention scope. This historical task must not be activated separately.

## Owner
Codex

## Purpose
Reduce antivirus/EDR friction through trust, provenance, packaging choices, and documentation without evasion.

## Scope
- Inventory embedded tools by source, publisher, version, hash, license, and expected behavior.
- Identify tools likely to trigger antivirus/EDR products.
- Recommend default-bundle versus optional Add-On placement.
- Create allowlisting/admin deployment guidance.
- Recommend removal or replacement for tools whose trust cost is too high.

## Out Of Scope
- Hiding tools from antivirus or EDR.
- Obfuscation, packing, encryption, stealth launchers, or bypass behavior.
- Downloading or installing replacement tools.

## Acceptance Criteria
- [ ] Tool provenance manifest or report exists.
- [ ] High-friction tools are clearly identified.
- [ ] Default-bundle/Add-On recommendations are documented.
- [ ] EDR/allowlisting guidance is written.
- [ ] No evasion behavior is added.
