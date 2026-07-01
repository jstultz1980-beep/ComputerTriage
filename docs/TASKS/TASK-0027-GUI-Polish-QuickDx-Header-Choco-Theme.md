# TASK-0027 - GUI Polish Quick Dx Header Choco Theme

## Status
Completed

## Owner
Codex

## Objective
Apply the requested GUI polish pass for the Quick Diagnosis page, header health badge, theme options, surface texture, and Chocolatey page layout.

## Scope
- Tighten the Quick Diagnosis right-column layout so Hardware Shortcuts do not get pushed down.
- Restore the header computer health status badge beside the computer name by giving the header summary more usable space.
- Add a dark terminal-style theme.
- Add a subtle gradient underneath the existing surface texture so pages are not flat solid color.
- Compact the Chocolatey status block so it does not span the whole Choco tab.
- Preserve existing button actions and diagnostics behavior.

## Out of Scope
- ARGUS implementation.
- HEPHAESTUS implementation changes.
- Tool installation, removal, or classification.
- Whole-application redesign beyond the targeted polish areas.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [x] Hardware Shortcut buttons sit higher inside Review And Shortcuts.
- [x] Header computer health badge is given usable space beside the computer name.
- [x] `Terminal Dark` is available as a theme option.
- [x] The page surface paint includes a subtle gradient plus texture.
- [x] Chocolatey status block is compact and no longer spans the whole tab.
- [x] Main GUI script parses successfully.
- [x] Existing smoke validation passes.
- [x] Existing button-smoke validation passes.

## Validation
- `powershell.exe -NoProfile -Command "[System.Management.Automation.PSParser]::Tokenize(...)"`
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest`
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest`

## Work Log
- 2026-07-01: Tightened Quick Dx right-side row sizing, restored health badge space, added Terminal Dark, expanded page texture to include a gradient, and compacted Choco status placement.
