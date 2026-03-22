# Visible Requirements

## Goal

Fix reconnect logic so unstable network conditions no longer cause visible watchdog resets.

## Constraints

- preserve ordinary telemetry delivery
- keep the patch local to reconnect and watchdog-handling code
- prefer a host-runnable or simulator-backed stress harness

## Public Pass Conditions

1. the firmware build succeeds
2. the public reconnect stress test no longer triggers a watchdog reset
3. normal telemetry still works

## Expected Working Set

- reconnect state machine
- watchdog feed logic
- timer configuration
- nearby packet handling if it directly affects reconnect behavior

## Hackathon Scope

This task is the firmware stretch or fallback for the 24-hour MVP.
