# Active Error Handoff

This tracked file is the cloud handoff from Codex to the Project Custodian when the Active task is blocked.

## Status
Clear

## Reporting Agent
None

## Active Task
None

## Error ID
None

## Severity
None

## Summary
No active blocking error is recorded.

## Blocking Condition
None.

## Evidence
None.

## Files And State Involved
None.

## Actions Already Attempted
None.

## Why Codex Cannot Continue Safely
Not applicable.

## Requested Project Custodian Decision
None.

## Recommended Remediation
None.

## Working-Tree Drift Preserved
None recorded by this handoff.

## Last Updated
Not set.

## Resolution
Not applicable.

---

## Codex Reporting Rules

When Codex reaches a genuine blocker or stop condition, it must:

1. Stop implementation without cleaning, discarding, or overwriting unrelated work.
2. Replace this file with a complete blocker report.
3. Set `Status` to `Blocked`.
4. Record the Active task, exact error, evidence, affected files, actions attempted, preserved drift, and the decision required from the Project Custodian.
5. Commit the blocker report with a message such as:
   `BLOCKED <TASK-ID>: Record error handoff for Project Custodian`
6. Push that blocker-report commit to the cloud repository even when normal task commits are local-only. This limited push is authorized because the Project Custodian must be able to read the report remotely.
7. Tell the user only that the blocker has been recorded and pushed, then wait for `Address Errors`.

Codex must not use this file for routine questions, low-risk implementation choices, or issues it can safely correct within the Active task.

## Project Custodian Rules

When the user prompts `Address Errors`, ChatGPT must:

1. Read `PROJECT.md`, `docs/HANDOFF.md`, `docs/TASKS/QUEUE.md`, and this file from the cloud repository.
2. Verify the error handoff is current and tied to the Active task.
3. Inspect all repository files needed to understand the blocker.
4. Resolve governance, architecture, task-scope, documentation, or sequencing conflicts directly in the repository when possible.
5. If code implementation is required, create or amend the smallest appropriate tracked task without discarding Codex work.
6. Preserve the Active task unless the blocker makes continuation impossible.
7. Update this file with the resolution and set `Status` to `Resolved` or `Clear`.
8. Update handoff/queue/task documents when the resolution changes project state.
9. Commit and push the remediation so Codex can resume from the cloud source of truth.
10. Give the user a concise instruction to tell Codex: `Resume Work`.
