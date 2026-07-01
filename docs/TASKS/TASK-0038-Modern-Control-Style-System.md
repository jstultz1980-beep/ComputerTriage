# TASK-0038 - Modern Control Style System

## Status
Queued

## Owner
Codex

## Objective
Replace default-looking utility buttons with a consistent, modern toolkit control style.

## Scope
- Define a reusable style/helper for small utility buttons such as Refresh, Stop, View, Open, and similar page actions.
- Apply the style to repeated utility buttons across the toolkit.
- Keep buttons compact enough to avoid layout overflow.
- Preserve accessibility:
  - Readable text.
  - Clear hover/focus state.
  - Disabled state that is visually obvious.
- Coordinate with existing theme colors so controls do not become washed out or unreadable.

## Out of Scope
- Full GUI redesign.
- Replacing every launch LED/tool button unless the control shares the same utility-button role.
- Theme-builder redesign.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [ ] Refresh/Stop-style controls no longer look like raw default buttons.
- [ ] Repeated utility controls use a shared style path.
- [ ] Button text remains readable in all built-in themes.
- [ ] No tab layout gains new clipping or forced scrolling from the style change.
- [ ] PowerShell parse, smoke, and button-smoke validation pass.
