# Software Tool Classification

## Purpose

The Software tab separates tools that can launch directly from the toolkit from installers or staged packages that need technician action before they should be treated as portable toolkit apps.

## Launchable Portable Apps

Launchable apps are read from the toolkit tool registry and custom-tool manifest. These should point to a runnable EXE, BAT, VBS, or supported launcher already stored inside the toolkit.

Examples include:
- Firefox Portable
- LibreOffice Portable
- Notepad++ Portable
- Draw.io Portable
- Sumatra PDF
- KompoZer

## Installable Or Extract-Needed Programs

These are stored in the toolkit but are not ready portable launchers. They stay visible so a technician knows the file exists, but they are labeled as installable or extraction-needed.

### Registrar Registry Manager

Current toolkit file:

```text
App\NetworkToolkit\ExternalTools\RegistrarRegistryManager\RegistrarHomeV9.exe
```

Classification:

```text
Installable / extract-needed
```

Reason:

Resplendence documents that Registrar Registry Manager is portable after it has been installed once and the installed program files are copied, but the toolkit currently contains only the installer EXE. Until the installed runtime files are copied into the toolkit, it must not appear as a normal portable launcher.

Sources:
- https://www.resplendence.com/registrar_faq
- https://www.resplendence.com/registrar

## Triage Tool Classification

The Triage tool list is reserved for portable diagnostic collectors that are not already better represented elsewhere in the toolkit.

Removed from the triage list:
- Sysinternals Suite: already managed by the toolkit SysTools and mapped tab integrations, and commonly flagged by endpoint protection.
- WinAudit: no current local executable is present and the legacy download path has been unreliable.

Kept as optional/manual:
- LatencyMon: portable diagnostic utility present under `App\Triage\Tools\LatencyMon`, but not an automatic collector. It should be launched manually when investigating latency, DPC, ISR, driver, or real-time audio symptoms.
