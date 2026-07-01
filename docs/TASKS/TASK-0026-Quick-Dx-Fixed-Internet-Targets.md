# TASK-0026 - Quick Dx Fixed Internet Targets

## Status
Completed

## Owner
Codex

## Objective
Remove the editable Quick Diagnosis internet test target and use a hard-coded primary/backup target chain.

## Scope
- Replace the editable Quick Diagnosis internet target box with a read-only display of fixed targets.
- Use `www.microsoft.com` as the primary target.
- Use `google.com`, `yahoo.com`, and `amazon.com` as backup targets.
- Pre-check targets in order and stop at the first successful HTTPS connection.
- Run Quick Diagnosis with the selected target.
- Preserve the separate Quick Target Checks target field.

## Out of Scope
- ARGUS implementation.
- HEPHAESTUS implementation changes.
- Quick Diagnosis report redesign.
- Tool installation, removal, or classification.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [x] Editable Quick Diagnosis internet target field is removed.
- [x] Fixed target chain is displayed in the Quick Diagnosis block.
- [x] Quick Diagnosis selects the first reachable HTTPS target.
- [x] Testing stops after the first successful target.
- [x] Quick Target Checks remain editable and unchanged.
- [x] Main GUI script parses successfully.
- [x] Existing smoke validation passes.
- [x] Existing button-smoke validation passes.

## Validation
- `powershell.exe -NoProfile -Command "[System.Management.Automation.PSParser]::Tokenize(...)"`
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`

## Work Log
- 2026-07-01: Added fixed target selection helpers and replaced the editable Quick Diagnosis target field with a static target-chain label.
