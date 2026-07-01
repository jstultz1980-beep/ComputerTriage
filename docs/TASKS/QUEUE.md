# Task Queue

## Lifecycle
The official task lifecycle is:

```text
Backlog
↓
Queued
↓
Assigned
↓
Active
↓
Validation
↓
Complete
↓
Archived
```

Only one task may be `Active` at a time.

## Active Task
| Task | Status | Owner | Next Owner | Notes |
|---|---|---|---|---|
| TASK-0010-Foundation-Audit | Active | ChatGPT | Codex | Governance-only foundation audit preparation task. This task name intentionally follows the current governance handoff request even though an earlier historical `TASK-0010-Classify-Drift-And-Status-Report.md` already exists. |

## Queued Tasks
| Task | Status | Owner | Notes |
|---|---|---|---|
| None | Queued | - | No queued implementation task until ChatGPT completes the foundation audit and creates follow-on tasks. |

## Recently Completed
| Task | Status | Owner | Notes |
|---|---|---|---|
| TASK-0016-Fix-Tool-Source-Of-Truth | Complete | Codex | Completed before this governance queue was introduced. |
