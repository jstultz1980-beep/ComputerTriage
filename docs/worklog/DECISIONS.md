# Decisions

## ARGUS location

ARGUS is a core engine and belongs in:

Core\ARGUS

Not:

Scripts\ARGUS

## ARGUS scope

Single-computer quick diagnosis only.

Not network-wide discovery, SIEM, RMM, asset inventory, or compliance engine.

## Error handling rule

If a script develops structural problems, rollback and rebuild clean. Do not keep stacking patches.
