# Sensitive Artifact and Runtime State Policy

## Storage Ownership

- `App` is the immutable program image. Shipped manifests are defaults and are never mutated by normal runtime use.
- `Runtime` is the writable deployment root. `Runtime/Data`, `Runtime/Exports`, `Runtime/Logs`, and `Runtime/State` own client evidence, reports, logs, and settings.
- `App/manifests/custom-tools.json` is the shipped default. Runtime discovery and technician changes use `Runtime/State/custom-tools.json`.
- Mutable portable-application directories are explicitly listed in `App/manifests/portable-state-policy.json`; folder names alone never authorize deletion.

## Artifact Classes

| Class | Examples | Default retention | Transfer default |
|---|---|---:|---|
| Operational | application logs and non-client state | 14 days | Included |
| ClientEvidence | diagnostic reports, inventories, triage output | 21 days | Included |
| Sensitive | licensing values, credentials/tokens, Wi-Fi profiles, dumps | 3 days | Excluded |

Artifact metadata uses a sibling `.ntk-artifact.json` record. A technician can pin an artifact with a reason. Retention uses this explicit metadata and never guesses preservation requirements from keyword sampling.

## Reveal and Export

Sensitive values are masked by default in the console, GUI, and ordinary reports. Reveal, clipboard copy, or unmasked export requires explicit technician confirmation. Each action is appended to `Runtime/Logs/SensitiveActions/audit.jsonl`. An unmasked software-key report receives the Sensitive class and three-day retention.

## Transfer

Client-data transfer is selective by artifact class. Sensitive content is excluded by default. Including Sensitive content requires authenticated password-based encryption; plaintext sensitive transfer is rejected. Destination capacity is preflighted, ordinary files are SHA-256 verified after copy, diagnostic bundle identities are verified, and the transfer manifest records selection, sensitivity, encryption, hashes, and failures.

## State Integrity

JSON runtime state uses an exclusive lock, validated temporary file, atomic replace, and backup. Read-modify-write operations on computer state occur inside the same lock so concurrent section updates are not lost. Interrupted writes leave the previous state intact. Invalid JSON is preserved with a timestamped `.corrupt-*` copy and reported instead of silently replaced.
