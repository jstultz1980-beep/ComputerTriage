# Handoff State And Fingerprint Protocol

## Purpose

Provide a single, symmetric, copyable handoff format so the user, Project Custodian, and Codex can immediately detect branch, commit, task, ownership, or synchronization mismatches before work begins.

This policy applies to every stop-boundary message from both ChatGPT/Project Custodian and Codex. It supplements the existing synchronization, timestamp, and final-operator-instruction rules. Where an older handoff example omits a field required here, this protocol controls.

## Mandatory Pre-Handoff Verification

Before producing a handoff, the reporting agent must verify the repository state used for its decision.

### Codex

Codex must:

1. Preserve documented working-tree drift.
2. Run `git fetch --prune origin`.
3. Compare local `HEAD` with `@{u}`.
4. Safely fast-forward with `git merge --ff-only @{u}` when local is behind and the operation does not threaten preserved drift.
5. Re-run the comparison.
6. Verify the checked-out branch and full local `HEAD` match the newest Project Custodian handoff.
7. Verify `docs/HANDOFF.md`, `docs/TASKS/QUEUE.md`, and the Active task file agree.

A fetch alone is not synchronization. Codex may not read stale local governance and may not resume implementation unless verification succeeds.

When local is ahead, diverged, lacks an upstream, cannot fast-forward safely, or does not match the Project Custodian handoff, Codex must report `Repository State Verified: NO`, state the reason, and use the Error Handoff procedure when required.

### Project Custodian

The Project Custodian must read the authoritative cloud branch directly, verify the current handoff, queue, error handoff, and Active task, and report the exact cloud commit produced or verified during the handoff.

## Mandatory Visible Handoff Block

Every stop-boundary response must include this block in the visible chat response:

```text
Repository State
----------------
Handoff ID: <HANDOFF-NNNN>
Current Branch: <branch>
Current HEAD: <full commit SHA>
Current Upstream: <origin/branch or authoritative cloud branch>
Upstream Comparison: <ahead> <behind>

Current Task: <task or None>
Current Owner: <owner>
Next Owner: <owner>

Repository State Verified: YES|NO
Verification Reason: <required when NO; use Verified when YES>
Preserved Drift: Unchanged|Changed as documented
Repository Fingerprint: Branch=<branch>;HEAD=<full commit SHA>;Task=<task or None>;Owner=<owner>;Handoff=<HANDOFF-NNNN>

Handoff Timestamp: YYYY-MM-DD HH:mm:ss CDT|CST
Next Command: <command>
```

The timestamp must use `America/Chicago` with the correct `CDT` or `CST` abbreviation.

## Verification Standard

`Repository State Verified: YES` is permitted only when all applicable checks pass:

- the reporting agent used the branch shown in the footer;
- the full `Current HEAD` is exact;
- Codex completed fetch and safe synchronization rather than fetch alone;
- Codex local `HEAD` equals upstream and the comparison is `0 0`;
- Codex local `HEAD` equals the newest Project Custodian handoff commit;
- `docs/HANDOFF.md` and `docs/TASKS/QUEUE.md` agree;
- the Active task file agrees with handoff and queue;
- task ownership agrees with all three records;
- preserved drift remains intact.

If any required condition fails, verification must be `NO`. The response must identify the mismatch and must not claim implementation authority.

## Repository Fingerprint

The fingerprint is mandatory and must use the exact full commit SHA:

```text
Repository Fingerprint: Branch=<branch>;HEAD=<full SHA>;Task=<task or None>;Owner=<owner>;Handoff=<HANDOFF-NNNN>
```

A fingerprint mismatch between Debbie and Codex means repository state is not verified, even when the timestamps are close.

## Final Operator Instruction

The existing exact final-instruction rules remain mandatory. The `Next Command` field must agree with the final line.

For a normal Project-Custodian-to-Codex handoff:

```text
Next Command: Resume Work

Resume Work
```

For a normal Codex-to-Project-Custodian handoff:

```text
Next Command: Tell Debbie to continue

Tell Debbie to continue
```

For a Codex blocker:

```text
Next Command: Tell Debbie to address errors

Tell Debbie to address errors
```

No text may appear after the final operator instruction.

## Mismatch Handling

When a copied Project Custodian handoff does not match Codex local state, Codex must first fetch and safely synchronize. It must not continue from its prior local task documents merely because those files are internally consistent.

When synchronization cannot produce the exact branch, full commit, task, owner, and Handoff ID supplied by the Project Custodian, Codex must stop with `Repository State Verified: NO` and report the exact mismatch.
