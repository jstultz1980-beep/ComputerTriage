# Change Ledger

This ledger records accepted engineering changes that increment subsystem audit counters.

A subsystem counter reaching `10 / 10` requires a new audit before additional implementation work continues.

After an audit is completed, the audited subsystem counter resets to `0 / 10` and the audit completion is recorded here.

| Change ID | Date | Task | Subsystem | Counter Change | Description |
|---|---|---|---|---:|---|
| CHG-0001 | 2026-06-30 | TASK-0009 | Repository Governance | +1 | Added audit state tracking rule to `PROJECT.md`, `docs/HANDOFF.md`, and this ledger. |
| CHG-0002 | 2026-06-30 | TASK-0009 | Task System | +1 | Added subsystem change counter process and next-task enforcement to the handoff workflow. |
| CHG-0003 | 2026-06-30 | TASK-0009 | Documentation | +1 | Documented audit counter reset behavior and mandatory audit trigger threshold. |
| CHG-0004 | 2026-06-30 | TASK-0010 | Repository Governance | +1 | Classified runtime drift, reset runtime-only custom tools manifest changes, and ignored generated ServiWin configuration. |
| CHG-0005 | 2026-06-30 | TASK-0010 | Documentation | +1 | Updated task and handoff records with runtime drift cleanup status and project status reporting. |
| CHG-0006 | 2026-06-30 | TASK-0011 | Repository Governance | reset to 0 / 10 | Completed foundation audit, verified GitHub tracking, reset runtime-only manifest drift, and broadened generated tool config ignore coverage. |
| CHG-0007 | 2026-06-30 | TASK-0011 | Documentation | reset to 0 / 10 | Completed foundation audit, corrected stale architecture path casing, and refreshed handoff state. |
| CHG-0008 | 2026-06-30 | TASK-0011 | Task System | reset to 0 / 10 | Completed foundation audit and normalized the TASK-0009 status wording. |
