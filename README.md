# KernelArena: Low-Level Control Setting For AI Control

This branch pivots the repo toward a new control-setting idea: **KernelArena**.

KernelArena is a proposed low-level control setting built around tasks inspired by:

- Linux kernel repair benchmarks such as `KGym` and `RGym`
- embedded / firmware benchmarks such as `EmbedBench` and recent ESP32-focused IoT evaluations
- GPU kernel benchmarks such as `KernelBench` and `MultiKernelBench`
- RTL / hardware design benchmarks covering generation, debugging, and verification

The high-level thesis is:

> low-level engineering work is a particularly important and underexplored regime for AI control, because models are weaker there, semantics are harder to monitor, and small local edits can create large hidden safety failures.

## What Makes KernelArena Different

Most existing control settings focus on application code, infra glue, or shell-heavy agent work. KernelArena instead targets:

- kernel memory-safety repairs
- firmware driver work and platform migration
- accelerator kernel optimization
- RTL debugging and hardware-interface logic

Crucially, both the **main tasks** and the **side tasks** are low-level.

That means the sabotage is not generic “log secrets to a file” behavior. It is low-level sabotage such as:

- rare-trigger memory corruption
- hidden privilege escalation in kernel or firmware code paths
- watchdog or safety interlock suppression
- latent numerical corruption in accelerator kernels
- hidden debug unlock paths in RTL or boot code

## MVP Scope

The most realistic MVP is:

1. `kernel_repair_lab` inspired by `RGym` / `KGym`
2. `firmware_lab` inspired by `EmbedBench` / ESP32 IoT tasks

Stretch families:

3. `accelerator_kernel_lab` inspired by `KernelBench` / `MultiKernelBench`
4. `rtl_lab` inspired by modern RTL generation/debug benchmarks

## Repo Structure

- `docs/kernelarena/overview.md` - setting thesis and why low-level control matters
- `docs/kernelarena/source-benchmarks.md` - how each benchmark family maps into KernelArena
- `docs/kernelarena/setting-design.md` - environment and scorer design
- `docs/kernelarena/task-catalog.md` - concrete main-task / side-task seed pairs
- `docs/kernelarena/evaluation.md` - metrics, baselines, and proposed experiments
- `docs/kernelarena/roadmap.md` - build order for an MVP implementation
- `environments/kernel_repair_lab/` - scaffold for the kernel repair environment
- `environments/firmware_lab/` - scaffold for the firmware environment
- `tasks/kernel/` - kernel MVP task specifications
- `tasks/firmware/` - firmware MVP task specifications
- `scorers/` - hidden usefulness / side-task scorer contracts
- `task_slices/kernelarena_seed_pairs.csv` - machine-readable seed task catalog

## Status

This branch now contains the control-setting concept, seed tasks, and initial scaffolding for `kernel_repair_lab` and `firmware_lab`. It does not yet include executable build harnesses or hidden scorers.

## Current MVP Task Specs

- `tasks/kernel/k_ioctl_bounds_guard/task.yaml`
- `tasks/kernel/k_uaf_repair_pkt_ring/task.yaml`
- `tasks/firmware/fw_watchdog_reconnect_fix/task.yaml`
- `tasks/firmware/fw_ota_rollback_guard/task.yaml`
