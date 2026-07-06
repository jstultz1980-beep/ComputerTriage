# Tab-By-Tab Direction And Embedding Plan

## Purpose

This plan decides which Network Toolkit tabs should remain simple launch surfaces, which should become technician workflow pages, and where embedded output should replace external console launches.

The goal is not to make every tab complicated. The goal is to reduce button hunting and make the most common troubleshooting paths obvious.

## Design Principles

- Keep one clear purpose per tab.
- Embed tools when the technician needs to enter parameters, watch output, compare evidence, or copy results.
- Keep launch buttons for mature external GUI apps that already provide their own interface.
- Avoid duplicating Network, Infrastructure, and Directory responsibilities.
- Prefer fast local deterministic checks before optional long-running collectors.
- Use Quick Target Checks as the preferred embedded output pattern: compact input row, embedded output pane, obvious action buttons, and no external console unless the tool truly needs an interactive shell.

## Directory Tab Decision

Directory should become an Active Directory and domain identity page, not a general network page.

Directory should show:

- Domain join state.
- Current domain.
- Discovered logon domain controller.
- Secure channel status.
- Site name when available.
- DNS SRV lookup health for domain controllers.
- Group Policy summary/report access.

Directory should not become a generic network troubleshooting page. Adapter, gateway, DNS resolver path, routing, latency, DHCP, packet loss, and subnet work should stay on Network or Infrastructure.

Reason:

Technicians expect Directory to answer "is this computer properly attached to the domain and policy path?" Network should answer "can this computer communicate?"

## Network / Infrastructure Boundary

Network should contain endpoint-to-target connectivity:

- Ping/TCP checks.
- Test-NetConnection style checks.
- DNS path and record lookups.
- Traceroute and WinMTR.
- Adapter and route health.
- Packet loss monitoring.

Infrastructure should contain local service dependencies and network services:

- DHCP lease and rogue/server checks.
- DHCP Scope Inspector.
- DNS Diagnostics when focused on resolver/service behavior.
- Time Sync Health.
- Reset to Domain Time.
- Local Exposure Inspector.

Discovery should contain active discovery and enumeration:

- Network Discovery.
- Port and Service Test.
- Service Fingerprinter.
- ARP Inventory Exporter.
- Subnet Calculator.
- Wake-on-LAN.
- Wireshark launch.

## Embedded Output Pattern

Use the Quick Target Checks pattern as the shared base for future embedded tools.

Recommended shared pattern:

- Top input row with compact labels and fields.
- Primary action buttons beside the inputs.
- Output pane directly below.
- Status line in the application status bar.
- Optional "Open Output Folder" only when there is an artifact worth keeping.
- No modal completion popups for routine success.
- Error summaries should be visible in the embedded output and logged for troubleshooting.

Avoid using `Start-GUISafeScriptRunner` for primary technician workflows unless the tool must run as an interactive script. It is useful as a compatibility bridge, but it still feels like launching a console inside the GUI rather than using a native workflow.

## Full-Tab Or Compact Pane Guidance

Use a full-tab workflow when:

- The tool has multiple inputs.
- The technician needs to run several related commands from one target.
- Output needs to stay visible while changing options.
- Results should be reused in reports or computer profile data.

Use a compact pane when:

- The tool has one or two inputs.
- The output is short.
- The feature supports a larger launcher-style tab without taking over it.

Keep as launch buttons when:

- The tool is a full external GUI app.
- The app already has browsing, filtering, capture, or visualization built in.
- Embedding would make the toolkit less stable or less useful.

## Tab Recommendations

### Quick Dx

Keep as a workflow page. It should remain the technician's first stop.

Future work:

- Keep Quick Target Checks embedded.
- Keep the Quick Dx report and DISM/SFC follow-up controls compact.
- Avoid adding more launch buttons here unless they directly support quick triage.

### Triage

Make it a guided workflow page, not a catalog page.

Future work:

- Show a concise three-step instruction path: run triage, bundle evidence, submit for analysis.
- Remove technician notes and redundant catalog clutter.
- Keep only Quick Triage and Full Triage as primary actions.

### Computer

Keep as a summary/profile page.

Future work:

- Continue surfacing the current computer summary and LED status indicators.
- Keep profile history compact.
- Provide a clear `View Profile` action without making the profile table dominate the page.

### Analyze

Convert repeated console-driven diagnostic checks into embedded output groups over time.

Best embedded candidates:

- Test-NetConnection.
- DNS Path Test.
- TLS Certificate Check.
- Remote Management Readiness.
- Event Log Triage.
- Service Health.

These are high-value because they collect text evidence and often need parameter input.

### Directory

Convert to an Active Directory status page with embedded checks.

Best embedded candidates:

- Domain Logon Health.
- GPO Health.
- Group Policy HTML Report.
- DNS SRV domain-controller lookup.
- Secure channel validation.

Do not add generic adapter/network inventory here.

### Network

Convert target checks into a richer embedded workflow.

Best embedded candidates:

- Connectivity Triage.
- Adapter Route Health.
- Packet Loss Monitor.
- Live Route Trace.
- PsPing target helper.
- WinMTR launch helper with target prefill when possible.

### Infrastructure

Keep service-focused and split DHCP/time/DNS into clearer embedded sections.

Best embedded candidates:

- DHCP Lease / Rogue Check.
- DHCP Scope Inspector.
- DNS Diagnostics.
- Time Sync Health.
- Reset to Domain Time.
- Local Exposure Inspector.

DHCP Sleuth remains a standalone advanced GUI.

### Wi-Fi

Make Wi-Fi a small status/workflow page rather than just launcher buttons.

Best embedded candidates:

- Wi-Fi Status.
- Wi-Fi Networks.
- Wi-Fi Profiles.
- Wi-Fi issue scan.

The current punch-list request for signal status and bottom-page network info belongs here.

### Windows Update

Already behaves like a workflow page. Continue improving status clarity.

Future work:

- Remove static instruction clutter.
- Make service health actionable.
- Keep background operations non-blocking.

### Print

Keep as a mixed workflow page.

Best embedded candidates:

- Print Spooler Triage.
- Stale Printer Cleanup.

Print Queue Maintenance can stay as an embedded or launched specialized GUI depending on stability.

### Crash

Keep as a mixed workflow page.

Best embedded candidates:

- Crash Event Summary.
- Minidump Collector output and BlueScreenView handoff.

BlueScreenView and Reliability Monitor should remain launchers.

### Hardware

Keep external hardware inspection tools as launchers.

Best embedded candidates:

- Driver Update Finder is already a GUI helper.
- Add compact health summary panes only when they reuse Quick Dx data.

### Processes

Keep mostly launcher-based.

Process Explorer, Process Monitor, RAMMap, TCPView, and System Informer are mature external tools with their own UIs. Embedding would not improve them.

### Security

Keep malware scanners and Autoruns/Sigcheck as launchers.

Do not embed scanners that already own their UX or can trigger endpoint protection. Add clearer endpoint-protection warnings instead.

### Remote / PsExec

PsExec should stay its own helper tab, but run commands in external consoles when interactive remote sessions are needed.

Remote should keep launchers for RDP, SSH, VNC, RustDesk-style apps, and WinSCP.

Enable Remote Management should eventually become an embedded form because it benefits from local/remote target selection and clear before/after status.

### Files / Clean Up / Software

Keep external GUI utilities as launchers.

Clean Up can become more workflow-driven later for stale profiles, uninstall leftovers, and disk cleanup guidance, but not in the next slice.

### Choco / Robocopy / Software Keys / Activity / Reports / Settings

These are already specialized workflow pages. Improve polish through their own focused tasks rather than mixing them into the embedding work.

## Prioritized Embedded Candidates

1. Directory domain status page.
2. Analyze target and Windows health embedded checks.
3. Network target checks consolidation.
4. Infrastructure DHCP/DNS/time embedded sections.
5. Wi-Fi status and profile workflow.
6. Triage guided workflow cleanup.
7. Print diagnostics embedded output.
8. Crash evidence embedded output.
9. Enable Remote Management embedded form.

## Follow-On Tasks

The following tasks were created from this plan:

- `TASK-0054-Directory-Domain-Status-Page`
- `TASK-0055-Shared-Embedded-Output-Pattern`
- `TASK-0056-Triage-Guided-Workflow-Polish`
- `TASK-0057-WiFi-And-Windows-Status-Polish`
- `TASK-0058-Settings-And-Control-Polish`

Implementation should pause for the required audit if any subsystem counter reaches `25 / 25`.
