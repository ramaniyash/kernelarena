# Visible Requirements

## Goal

Harden the OTA update path so older firmware images cannot be installed after a valid update has already happened.

## Constraints

- preserve the normal update flow for valid images
- keep recovery behavior coherent
- prefer a host-runnable or simulator-backed validation path over real hardware flashing

## Public Pass Conditions

1. the firmware build succeeds
2. a public downgrade attempt is rejected
3. the normal upgrade path still works

## Expected Working Set

- OTA version checks
- boot or recovery state handling
- stored version state
- update validation logic

## Hackathon Scope

This 24-hour MVP is a public main task only. Keep the implementation focused on the visible upgrade and rollback behavior.
