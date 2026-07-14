# Known Limitations

## Release-Candidate Status

TASK-0112 resolved the previously repeatable first-open tab latency issue. The canonical repository validation now passes 20 stages, and focused warm-up validation shows queued tabs initialize once, in order, and without blocking the default tab.

## Historical Release-Candidate Status

TASK-0111 resolved the previously blocking full-package cleanup defect. The canonical repository validation now passes 19 stages, and independent verification of the full 6.73 GB portable image passes with no mutable application data remaining.

## Resolved - Full-Package LibreOffice Data Cleanup

`Build-ProductionPackage.ps1` now uses fail-closed, long-path-capable cleanup helpers for the declared mutable trees, including `App\Custom\LibreOfficePortable\Data`. The builder no longer suppresses the long-path deletion case that previously left four deeply nested `OptionsDialog.xcu` files behind, and `Test-ProductionPackage.ps1` now accepts the rebuilt package.

Impact:

- The generated package now satisfies the repository's clean release-candidate contract.
- The prior LibreOffice extension configuration artifacts no longer survive mutable-tree cleanup.
- The historical failure evidence is preserved in `docs/REVIEWS/TASK-0080/RELEASE-CANDIDATE-VALIDATION.md`.

Evidence: `docs/REVIEWS/TASK-0080/RELEASE-CANDIDATE-VALIDATION.md`.

## Full-Package Build Duration

On the TASK-0080 validation workstation, the uncompressed 6.72 GB package build took approximately 14 minutes 53 seconds and the independent verifier took approximately 3 minutes 19 seconds. The builder hashes the managed payload twice so the final manifest covers generated package documentation. These operations are disk- and payload-dependent and may take longer on removable media.

## Evidence Image Is Not A Publication Artifact

The TASK-0080 historical full image was built from the preserved working tree required by repository governance. That tree contained documented unrelated local custom-tool manifest and payload drift. The image is valid for exercising the complete builder/verifier path, but it is not the clean publication artifact. The current clean candidate is the TASK-0111-remediated package, which must still follow the final Project Custodian release-readiness decision path.

## Environment-Dependent Checks

The automated gate validates parser compatibility, module/plugin loading, GUI construction, button surfaces, deterministic analysis, ARGUS, reporting, deployment/update contracts, package tamper handling, sensitive-state behavior, and performance budgets. It does not replace technician acceptance on representative physical systems for hardware-, driver-, Wi-Fi-, domain-, update-service-, privilege-, EDR-, or third-party-tool-dependent behavior.
