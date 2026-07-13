# Reporting and Run Index Contract

## Purpose

Network Toolkit reports use one shared contract for output escaping, report metadata, immutable run identity, and artifact discovery. The contract prevents presentation-specific escaping from drifting and prevents a directory timestamp from being treated as evidence of which diagnostic run is newest.

## Canonical implementation

`App/NetworkToolkit/Utilities/ReportingContract.ps1` owns:

- HTML text encoding and Markdown field escaping.
- Required report metadata and its validated run identity.
- Immutable run identity and artifact records.
- Latest-run selection by `collectionStartedUtc`, with `runId` as a deterministic tie breaker.
- Runtime artifact resolution as `Available`, `Stale`, or `Missing`.

Compatibility wrappers may retain an older function name, but they must delegate escaping to the canonical helper.

## Report metadata

Every indexed report has schema version, report ID, report type, title, format, generation time, source artifacts, limitations, and exactly one run identity. A valid identity requires `runId`, `bundleId`, `computerName`, and `collectionStartedUtc`.

Report metadata is stored in the immutable artifact record. It is not inferred later from a filename or parent directory.

## Run index

The default index is `Runtime/Data/RunIndex`. Each run is stored in a directory named from a deterministic SHA-256 prefix of its `runId`; the original identity remains inside `identity.json`. The compact key keeps atomic writes within Windows path limits. Registering the same identity is idempotent. Reusing a run ID with conflicting identity fields is rejected.

Artifact records include the recorded path, length, SHA-256 digest, artifact type, registration time, and report metadata. An artifact record is immutable. If a producer replaces report content at the same path, the replacement receives a distinct artifact record and the previous record resolves as stale.

## Discovery and state

Latest-run selection sorts indexed identities by the collection timestamp, not directory creation or modification time. Report discovery gives indexed artifacts this same run order. Legacy, unindexed export files remain visible for compatibility but do not define latest-run state.

Artifact resolution is explicit:

- `Available`: the file exists and its length and digest match the immutable record.
- `Stale`: the path exists but its content no longer matches the record.
- `Missing`: the indexed path no longer exists.

Consumers must not silently substitute a stale or missing artifact as the current report.
