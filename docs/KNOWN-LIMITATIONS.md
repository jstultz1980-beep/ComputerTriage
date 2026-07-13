# Known Limitations

## Release-Candidate Status

The 2026-07-13 TASK-0080 release-candidate evidence does not support declaring Version 1.0 release-ready yet. The canonical repository validation passed all 18 stages, but independent verification of the full 6.72 GB portable image failed the clean-package data check described below.

## Full-Package LibreOffice Data Cleanup

`Build-ProductionPackage.ps1` applies the mutable-path policy to `App\Custom\LibreOfficePortable\Data`, but Windows PowerShell 5.1 recursive deletion leaves four deeply nested `OptionsDialog.xcu` files under long temporary extension-registry paths. The builder suppresses those deletion errors, includes the surviving files in `ProductionManifest.json`, and completes successfully. `Test-ProductionPackage.ps1` then correctly rejects the image because a portable application `Data` directory is not empty.

Impact:

- The generated package is not a clean release candidate under the repository's current package contract.
- The four observed files are LibreOffice extension configuration artifacts, not toolkit diagnostic reports, but their survival proves the cleanup contract is not fail-closed.
- Do not publish, tag, or distribute this release candidate until the Project Custodian accepts a focused remediation or explicitly accepts the risk in writing.

Evidence: `docs/REVIEWS/TASK-0080/RELEASE-CANDIDATE-VALIDATION.md`.

## Full-Package Build Duration

On the TASK-0080 validation workstation, the uncompressed 6.72 GB package build took approximately 14 minutes 53 seconds and the independent verifier took approximately 3 minutes 19 seconds. The builder hashes the managed payload twice so the final manifest covers generated package documentation. These operations are disk- and payload-dependent and may take longer on removable media.

## Evidence Image Is Not A Publication Artifact

The TASK-0080 full image was built from the preserved working tree required by repository governance. That tree contained documented unrelated local custom-tool manifest and payload drift. The image is valid for exercising the complete builder/verifier path, but it is not a reproducible publication artifact tied only to the recorded source commit. After package cleanup is remediated or accepted, create the actual release from an approved clean source/payload state and rerun independent verification.

## Environment-Dependent Checks

The automated gate validates parser compatibility, module/plugin loading, GUI construction, button surfaces, deterministic analysis, ARGUS, reporting, deployment/update contracts, package tamper handling, sensitive-state behavior, and performance budgets. It does not replace technician acceptance on representative physical systems for hardware-, driver-, Wi-Fi-, domain-, update-service-, privilege-, EDR-, or third-party-tool-dependent behavior.
