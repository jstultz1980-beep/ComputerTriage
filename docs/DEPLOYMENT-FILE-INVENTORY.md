# Deployment File Inventory

This inventory separates field-runtime files from development-only files for Network Toolkit deployment and update logic.

## Runtime-Required

These files and folders are required in a deployed toolkit:

- `NetworkToolkit.vbs` at the deployment root: hidden/elevated launcher.
- `App/NetworkToolkit.ps1`: PowerShell entry point for GUI or CLI launch.
- `App/ToolKit-GUI/`: Windows Forms GUI.
- `App/NetworkToolkit/Config/`: command registry, catalog, and path configuration.
- `App/NetworkToolkit/Core/`: shared runtime analysis and support modules.
- `App/NetworkToolkit/Discovery/`: runtime discovery modules.
- `App/NetworkToolkit/Plugins/`: technician tools and GUI-backed plugin logic.
- `App/NetworkToolkit/UI/`: console UI runtime support.
- `App/NetworkToolkit/Utilities/`: shared runtime utility modules.
- `App/NetworkToolkit/Docs/`: local help file and technician-facing documentation shown from the toolkit.
- `App/NetworkToolkit/ExternalTools/`: portable runtime tools, unless explicitly excluded by deployment options such as Sysinternals exclusion.
- `App/Triage/Templates/`, `App/Triage/Tools/`, and `App/Triage/README.md`: triage runtime templates and approved triage tools.
- `App/Custom/`: portable toolbox apps on fresh deployment.
- `App/manifests/toolkit-version.json`: source-of-truth toolkit version and build metadata.
- `App/manifests/custom-tools.json`: immutable toolbox defaults on fresh deployment.
- `App/manifests/portable-state-policy.json`: explicit mutable/immutable path ownership.
- `App/Update-NetworkToolkit.ps1`: field update engine.
- `App/Deploy-NetworkToolkit.ps1`: fresh deployment engine.
- `App/DeploymentExclusions.ps1`: shared deployment/update exclusion policy.

## Client Data

Client data is intentionally excluded from fresh deployment and deployed toolkit updates unless the dedicated client-data transfer workflow is used:

- `Runtime/Data/`
- `Runtime/Exports/`
- `Runtime/Logs/`
- `Runtime/State/`
- `App/Triage/Runs/`
- `App/Triage/Profiles/`
- `App/logs/`

## Destination-Preserved Runtime State

The updater preserves these destination files because they are technician/runtime state for that copy:

- `Runtime/State/gui-settings.json`
- `Runtime/State/custom-tools.json`
- `Runtime/State/custom-tools.json.bak`
- `App/Custom/`
- `App/NetworkToolkit/ExternalTools/`

## Development-Only

These are source-maintenance files and should not be deployed to production thumb drives or copied by toolkit updates:

- Root `.git/`
- Root `docs/`
- Root `PROJECT.md`
- Root `README.md`
- Root `punch_list.txt`
- `App/Build-ProductionPackage.ps1`
- `App/Test-ProductionPackage.ps1`
- `App/Update-ToolkitVersion.ps1`
- `App/NetworkToolkit/Tests/`
- Any `Release/` folder under a deployment source.

## Policy Owner

The implementation source of truth is `App/DeploymentExclusions.ps1`.

Fresh deployment and toolkit update scripts must call that helper instead of maintaining separate hard-coded exclusion lists.
