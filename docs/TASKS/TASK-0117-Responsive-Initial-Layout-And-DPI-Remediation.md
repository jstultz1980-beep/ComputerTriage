# TASK-0117 - Responsive Initial Layout And DPI Remediation

## Status
Active

## Owner
Codex

## Depends On
- TASK-0116 Project Custodian Documentation Engineering Audit.
- Real-world field-test evidence captured from the default toolkit launch view.

## Objective
Correct the default-launch layout so the complete primary interface fits within the usable client area without right-side clipping, while preserving existing behavior, visual hierarchy, and PowerShell 5.1 compatibility.

## User Evidence
The default view after launching the toolkit on representative hardware clips the right side of the primary interface. The right-side action and shortcut panels extend beyond the visible client area. This is a release-quality usability defect discovered during real-world testing.

A separate status-bar error reports that `Write-GUILog` is unavailable during deferred startup tab construction. That defect is explicitly out of scope for TASK-0117 and must be tracked separately.

## Scope
- Reproduce the clipping using the current default window launch path.
- Identify fixed widths, absolute positions, premature layout calculations, missing docking/anchoring, scaling assumptions, or minimum-size conflicts responsible for horizontal overflow.
- Make the header, tab strip, content area, right-side panels, and status bar fit within the actual client area at initial launch.
- Preserve the intended default window state and avoid merely hiding content with horizontal scrolling.
- Support resizing down to a documented minimum usable client size.
- Verify Windows display scaling at 100%, 125%, 150%, and 200% where test infrastructure permits.
- Verify representative resolutions including 1920x1080 and at least one narrower supported desktop resolution.
- Add focused deterministic layout validation that detects controls extending beyond their parent/client bounds.
- Preserve Settings-only access to the Performance Dashboard.
- Update toolkit build metadata and required task, validation, changelog, ledger, queue, roadmap, and handoff records.

## Out Of Scope
- Broad UI redesign or visual restyling.
- Reordering or removing primary features to make them fit.
- The deferred startup `Write-GUILog` failure.
- New diagnostic features, helper frameworks, or native replacements.
- Modifying the published `v1.0.0` tag or release artifacts.

## Required Design Behavior
1. Layout decisions must use the final available client size rather than assuming a fixed desktop width.
2. Parent containers must own sizing through appropriate docking, anchoring, autosizing, or calculated bounds.
3. No visible primary control may extend beyond its parent client rectangle at launch.
4. Resizing must not produce overlapping controls, inaccessible buttons, or clipped text at the supported minimum size.
5. DPI/scaling behavior must not multiply fixed dimensions into overflow.
6. The fix must not introduce synchronous startup work or regress TASK-0112/TASK-0114 performance behavior.

## Acceptance Criteria
- [ ] Default launch shows the complete right side of the interface without clipping.
- [ ] Header, navigation rows, main content, right-side panels, and status bar remain inside the client area.
- [ ] Supported window resizing does not create overlap or inaccessible controls.
- [ ] Focused layout-boundary validation passes.
- [ ] GUI smoke and button-smoke pass.
- [ ] Cold-tab warm-up and performance QA validation remain passing.
- [ ] PowerShell 5.1 parser validation passes.
- [ ] Canonical repository validation passes or all applicable focused regression suites pass with documented justification.
- [ ] The `Write-GUILog` startup defect is recorded separately and not silently folded into this task.
- [ ] Preserved drift remains untouched.

## Required Evidence
- Before/after screenshots or captured layout dimensions for the default launch.
- Root-cause explanation identifying the layout assumptions that caused clipping.
- Supported resolution and scaling test matrix.
- Automated boundary-check results.
- GUI smoke, button-smoke, parser, performance, and regression results.

## Rollback Plan
Revert the focused layout/container changes and associated validation while preserving all unrelated drift and post-release work. Return the field-test defect to the Project Custodian with the failed evidence.
