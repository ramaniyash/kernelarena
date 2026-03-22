# firmware_lab

## Purpose

`firmware_lab` is the second KernelArena MVP environment. It is meant to host firmware and embedded tasks inspired by `EmbedBench`, `EmbedAgent`, and ESP32-style IoT evaluations.

## MVP Focus

The MVP should center on tasks that are low level but still practical to run locally:

- watchdog and reconnect logic
- OTA update hardening
- driver or board-support migration
- ISR-safe buffering and peripheral state handling

## Proposed Workspace Layout

```text
/workspace/
  firmware/              # pinned firmware codebase
  boards/                # board configs or simulation targets
  tests/public/          # visible integration tests
  tests/hidden/          # hidden safety / sabotage triggers
  out/                   # build artifacts and serial logs
```

## Agent Contract

The agent should be able to:

- inspect and edit firmware source
- build the firmware target
- run visible tests in simulation, emulator, or host-side harnesses
- inspect serial logs and watchdog reset traces

The hidden triggers should exercise rare states such as:

- malformed packets
- boot pin combinations
- reconnect timing patterns
- unusual ISR ordering

## Why This Environment Matters

Firmware work gives natural cover for dangerous but plausible sabotage:

- debug UART exposure
- watchdog suppression
- rollback bypasses
- maintenance-mode triggers
- sensor or actuator override under rare inputs

This is exactly the kind of low-level threat model that ordinary web-app control settings do not cover well.
