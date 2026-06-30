# TASK-0014 - Restore DHCP Sleuth

## Status
Completed

## Owner
Codex

## Objective
Restore DHCP Sleuth as a stable toolkit app so it appears on the Infrastructure
tab and survives runtime manifest cleanup.

## Scope
- Track the DHCP Sleuth standalone tool files that belong with the toolkit.
- Keep DHCP Sleuth mutable settings out of source control.
- Register DHCP Sleuth in the custom tools manifest with standalone GUI launch
  behavior.
- Validate the GUI loads and the button smoke test passes.

## Out of Scope
- Redesigning DHCP Sleuth.
- Changing DHCP diagnostic behavior.
- Moving unrelated custom apps into source control.
- HEPHAESTUS collection baseline work.

## Files to Create or Modify
- `App/.gitignore`
- `App/Custom/DHCPSleuth/**`
- `App/manifests/custom-tools.json`
- `docs/HANDOFF.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- `docs/HISTORY/CHANGELOG.md`
- `docs/TASKS/TASK-0014-Restore-DHCP-Sleuth.md`

## Acceptance Criteria
- [x] DHCP Sleuth files are preserved in the repository.
- [x] DHCP Sleuth settings remain ignored as runtime data.
- [x] DHCP Sleuth is registered in `custom-tools.json`.
- [x] DHCP Sleuth maps to the Infrastructure tab.
- [x] Smoke tests pass.

## Validation Steps
```powershell
git status --short --branch
git check-ignore -v App/Custom/DHCPSleuth/DHCP-Sleuth.settings.json
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest
```

## Rollback Plan
Revert the DHCP Sleuth manifest entry, the `App/.gitignore` exceptions, tracked
DHCP Sleuth files, and related project tracking docs.

## Work Log

### Entry 001
Author: Codex
Date: 2026-06-30
Summary: Created task after DHCP Sleuth disappeared from the GUI.
Files Changed:
- `docs/TASKS/TASK-0014-Restore-DHCP-Sleuth.md`
Validation Performed:
- Confirmed DHCP Sleuth exists under `App\Custom\DHCPSleuth`.
- Confirmed `App/Custom/*` ignore rule hid DHCP Sleuth from Git.
- Confirmed current custom tools manifest does not register DHCP Sleuth.
Issues:
- Existing GUI smoke tests can mutate `custom-tools.json` through custom-tool
  provenance migration; reset runtime drift before committing.
Instructions for Next Owner:
- Restore DHCP Sleuth as a tracked, registered toolkit app.

### Entry 002
Author: Codex
Date: 2026-06-30
Summary: Restored DHCP Sleuth as a tracked standalone toolkit app.
Files Changed:
- `App/.gitignore`
- `App/Custom/DHCPSleuth/DHCP-Sleuth.ps1`
- `App/Custom/DHCPSleuth/README.md`
- `App/Custom/DHCPSleuth/VERSION`
- `App/Custom/DHCPSleuth/assets/dhcp-sleuth-magnifier-source.png`
- `App/Custom/DHCPSleuth/assets/dhcp-sleuth-magnifier.png`
- `App/manifests/custom-tools.json`
- `App/NetworkToolkit.ps1`
- `App/ToolKit-GUI/ToolKit-GUI.ps1`
Validation Performed:
- Confirmed DHCP Sleuth settings are ignored by `App/.gitignore`.
- Parsed `App/NetworkToolkit.ps1`.
- Parsed `App/ToolKit-GUI/ToolKit-GUI.ps1`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`.
- Ran `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`.
Issues:
- Smoke tests initially appeared to hang because `App/NetworkToolkit.ps1`
  enforced the single-instance mutex even for test mode while a GUI instance
  was already running. Test mode now bypasses the singleton guard.
- Runtime custom-tool provenance migration still mutates
  `App/manifests/custom-tools.json`; that drift was reset before commit.
Instructions for Next Owner:
- Continue with the next focused task from `docs/HANDOFF.md`.

## Completion Notes
DHCP Sleuth is back in the tracked toolkit under `App/Custom/DHCPSleuth` and is
registered as a standalone GUI tool on the Infrastructure tab. The mutable
`DHCP-Sleuth.settings.json` file remains ignored so per-machine settings do not
pollute the repository.
