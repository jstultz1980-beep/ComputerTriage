# TASK-0113 - Version 1.0 Release Publication

## Status
Active

## Owner
Codex

## Depends On
- TASK-0080 release-readiness acceptance.
- Explicit user authorization to execute the Version 1.0 release.

## Objective
Publish the accepted Version 1.0 release from the authoritative release branch without altering product behavior or disturbing preserved drift.

## Scope
- Synchronize the local checkout with the authoritative cloud branch before trusting release state.
- Verify the accepted release commit and repository state.
- Create the Version 1.0 tag using the repository's established version naming convention.
- Create the GitHub Release from the accepted release notes.
- Attach only approved release artifacts that are present and verified.
- Record the published tag, release URL, commit, artifact checksums, and publication timestamp.
- Update handoff, queue, changelog, ledger, and release records as required.

## Out Of Scope
- New features or fixes.
- Rebuilding or modifying the accepted release candidate unless a release-blocking defect is found.
- Cleaning or staging unrelated working-tree drift.
- Publishing unverified artifacts.
- Beginning Version 1.1 planning.

## Acceptance Criteria
- [ ] Local and upstream release branch are synchronized before release execution.
- [ ] The release commit matches the accepted Project Custodian decision.
- [ ] Version 1.0 tag is created and points to the accepted commit.
- [ ] GitHub Release is published with approved release notes.
- [ ] Any attached artifacts pass existing integrity verification and checksums are recorded.
- [ ] Repository records identify the final tag, release URL, commit, and publication timestamp.
- [ ] Preserved drift remains untouched.
- [ ] Control returns to the Project Custodian for release closeout confirmation.

## Blocker Rule
If tagging, release creation, artifact verification, permissions, branch synchronization, or publication fails, record the complete blocker in `docs/ERROR-HANDOFF.md`, push the minimum blocker handoff, and stop without partial or guessed remediation.
