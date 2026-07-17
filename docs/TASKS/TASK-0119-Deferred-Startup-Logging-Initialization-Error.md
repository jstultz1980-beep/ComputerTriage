# TASK-0119 - Deferred Startup Logging Initialization Error

## Status
Active

## Owner
Codex

## Priority
Release-defect remediation. This task preempts TASK-0118, which remains queued and unchanged.

## Objective
Eliminate the confirmed deferred-startup failure where `Write-GUILog` is invoked before it is available, without suppressing diagnostics or broadening scope into unrelated startup optimization.

## Confirmed Symptom
The toolkit status area reports that deferred startup tab construction failed because `Write-GUILog` is not recognized as a cmdlet, function, script file, or executable program.

## Required Work
- Reproduce the failure on a normal interactive launch.
- Trace the exact deferred callback, runspace, scope, import, and initialization order involved.
- Determine whether the defect is caused by function-definition order, script/module scope, closure capture, runspace isolation, or an incorrect dependency boundary.
- Fix the dependency contract so deferred startup code can log safely after the GUI shell is created.
- Do not hide the exception, replace it with silent failure, or disable deferred startup merely to remove the message.
- Ensure fallback error reporting remains available if GUI logging itself cannot initialize.
- Search deferred callbacks for other helper functions with the same scope/order risk and address only directly equivalent defects proven by the same root cause.

## Validation
- Windows PowerShell 5.1 parser validation.
- Interactive launch reproducer proving the original failure no longer occurs.
- Focused test covering deferred execution before and after logger initialization.
- GUI smoke and button smoke.
- Warm-up queue and background-operation lifecycle tests.
- Canonical repository validation.
- Negative-path validation proving logging failure is surfaced without recursive logging failure.

## Constraints
- Preserve unrelated working-tree drift.
- Preserve published `v1.0.0` artifacts and tag.
- Do not perform TASK-0118 performance optimization in this task.
- Do not create a second logging framework.

## Acceptance Criteria
- [ ] Root cause documented with the exact call path and scope boundary.
- [ ] Normal launch produces no `Write-GUILog is not recognized` deferred-startup error.
- [ ] Deferred startup failures remain visible and actionable.
- [ ] Equivalent proven initialization-order defects are covered by focused validation.
- [ ] Required regression gates pass.
- [ ] TASK-0118 remains queued for resumption after this defect is closed.
