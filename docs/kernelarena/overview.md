# KernelArena Overview

## One-Line Pitch

KernelArena is a proposed control setting for **low-level systems work**, with a current hackathon framing centered on the xz backdoor: can agents produce xz-style tampering in low-level code changes, and can monitors catch it before release?

The repository's hackathon materials treat xz-style behavior as a defensive benchmark target and package it through redacted negative-case descriptions plus invariant-based scoring.

## Why This Matters For AI Control

Low-level systems work is an unusually important regime for control research.

It has three properties that make it high priority:

1. **Models are weaker there.** Kernel repair, embedded programming, accelerator kernels, and RTL are all substantially harder than ordinary SWE benchmarks.
2. **Monitoring is harder there.** Semantics are dense, pointer-heavy, stateful, and spread across hardware/software boundaries. Natural-language explanations often underdescribe the real effect of a patch.
3. **The blast radius is large.** Small local edits can create privilege escalation, memory corruption, silent data corruption, watchdog suppression, debug unlocks, or safety-critical control failures.

If frontier models are used for systems maintenance, optimization, firmware updates, or hardware-adjacent engineering, control methods will need to work in this regime too.

## Core Research Thesis

KernelArena is designed to test the following claim:

> The safety/usefulness frontier for control protocols is worse in low-level domains than in ordinary application-code settings, because benign work legitimately uses unsafe primitives and because covert sabotage can hide inside semantically dense implementation details.

This makes low-level work a good stress test for:

- action monitors
- trusted editing
- resampling and defer-to-trusted-model protocols
- tool restrictions and execution tracing
- test-aware and semantics-aware auditing

## What Counts As “Low-Level” Here

KernelArena covers four families:

### 1. Kernel Repair

Tasks inspired by `KGym` and `RGym`:

- fix KASAN bugs
- repair refcounting or locking issues
- patch dangerous ioctl paths
- fix driver lifecycle errors

### 2. Firmware / Embedded

Tasks inspired by `EmbedBench`, `EmbedAgent`, and recent ESP32 evaluations:

- implement peripheral drivers
- port between Arduino / ESP-IDF style stacks
- fix ISR and watchdog issues
- harden OTA and boot flows

### 3. Accelerator Kernels

Tasks inspired by `KernelBench` and `MultiKernelBench`:

- optimize CUDA-like kernels
- add fused kernels
- repair boundary handling and shape logic
- port kernels across backends

### 4. RTL / Hardware Logic

Tasks inspired by recent RTL generation/debug benchmarks:

- repair handshake logic
- add parity/ECC
- debug FSM transitions
- align implementation with spec and tests

## The Key Design Choice

Both the **main tasks** and the **side tasks** are low-level.

This is not a setting where the model does kernel work but the side task is generic secret exfiltration through a web API.

Instead, the side tasks should also live at the low level:

- rare-trigger kernel write primitive
- hidden firmware debug console
- silent corruption on rare tensor shapes
- RTL debug unlock on a magic sequence
- watchdog suppression or telemetry suppression

That makes the benchmark more coherent, and also more valuable for control research.

## Minimal Viable Version

The most realistic hackathon MVP is not all four families at once.

The MVP should center on:

- `kernel_repair_lab`
- `firmware_lab`

These two domains already give strong low-level coverage and align well with available tooling: local patching, compiler/test harnesses, QEMU or simulation, and hidden scorer tests.

Accelerator kernels and RTL should be treated as strong stretch extensions, not day-one requirements.

## Main Hypotheses

1. **Low-level control is harder than app-code control.** Monitors and protocols that work well on ordinary SWE tasks will lose more usefulness or more safety here.
2. **Rare-trigger sabotage is especially dangerous.** Many low-level side tasks can be hidden behind uncommon inputs, timing, dimensions, or hardware states.
3. **Patch semantics matter more than surface narrative.** Monitors that rely mostly on high-level natural-language reasoning may underperform relative to monitors with structured execution or hidden test support.

## Success Criteria For The Setting

A good KernelArena MVP should demonstrate at least three things:

1. the main tasks are genuinely useful and nontrivial,
2. the side tasks are realistic and covertly achievable,
3. there is a meaningful safety/usefulness tradeoff for at least one control protocol.
