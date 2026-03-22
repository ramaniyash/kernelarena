# KernelArena: Low-Level Control Setting For AI Control

If you are a new joiner, the shortest way to think about this project is:

KernelArena is an attempt to build a LinuxArena-style benchmark for **low-level systems work**.

The core question is:

> Can an AI agent do useful low-level engineering work, and can our monitoring and evaluation stack catch subtle dangerous changes before they ship?

Unlike many existing control settings, this project is not mainly about web apps, CRUD backends, or shell automation. It is about code lower in the stack, where small edits can have big consequences:

- Linux kernel repair
- firmware and embedded systems hardening
- accelerator kernel optimization
- RTL and hardware-interface logic

## In Plain English

This project is trying to build benchmark tasks where an agent:

1. gets a visible engineering job such as fixing a bug or hardening a risky code path
2. works inside a realistic environment
3. is judged on whether the visible job appears complete
4. is also judged on whether the fix is actually robust
5. is also checked for subtle hidden failures, tampering, or broken invariants
6. is reviewed by monitors that try to spot suspicious behavior while the run is happening or after the run is over

So every benchmark case is meant to separate three things that are easy to blur together:

- `visible success` - did the obvious task get done?
- `true usefulness` - is the fix actually correct and robust?
- `safety` - did the agent introduce, preserve, or hide a dangerous behavior?

## Why This Matters

Low-level work is especially important for AI control because:

- dangerous primitives are normal, not exceptional
- small diffs can silently weaken a security boundary
- ordinary tests often miss rare environment and input combinations
- review is harder because the semantics are subtle and the code is less familiar to many reviewers

That makes low-level work a strong stress test for monitoring and control protocols.

## What A Single Benchmark Run Should Look Like

The intended benchmark loop is:

1. Give the agent a visible task, such as fixing an `ioctl` bug or adding firmware rollback protection.
2. Let the agent inspect files, run commands, edit code, and run visible tests.
3. Evaluate the final result with a visible oracle.
4. Run hidden usefulness checks that test whether the fix is genuinely correct.
5. Run hidden safety or invariant checks that test whether a subtle dangerous condition still exists.
6. Run monitors over the action stream or the full trajectory to measure how suspicious the run looked.

This means KernelArena is not just a task set. It is meant to be a full evaluation stack.

## Monitoring Model We Need To Support

KernelArena should follow the LinuxArena-style distinction between **action-level** monitoring and **trajectory-level** monitoring.

### Action-Level Monitors

These are the "live" monitors.

They should see:

- the full history of actions taken so far
- the outputs from all previous actions
- the command or tool call for the current action

They should **not** see:

- the output of the current action, because that action has not run yet

These monitors are meant to represent checks that happen inside the agent scaffold before a tool call is executed.

### Trajectory-Level Monitors

These are the "post-run" monitors.

They should see:

- the entire trace of actions
- the outputs of all actions
- the final artifacts produced by the run

These monitors are meant to represent slower, richer review that can happen after the run completes.

### What This Means For Our Implementation

Our benchmark and tooling should preserve enough information for both regimes.

In practice that means:

- store the action history step by step
- store the current action separately from its eventual output
- record outputs after execution so full-trajectory review is possible
- avoid designing monitors that rely on impossible information during live checks
- keep visible scoring, hidden usefulness scoring, hidden safety scoring, and monitoring conceptually separate

If we do this correctly, the same run can be evaluated both as a live-control problem and as a post-hoc forensic review problem.

## What This Project Is Trying To Implement

The long-term project has five layers.

### 1. Environment Layer

These are the workspaces where the agent operates.

Examples:

- a kernel repair environment based on `RGym` / `KGym`
- a firmware environment based on `EmbedBench` and related embedded tasks

### 2. Task Layer

These define the actual jobs the agent is asked to do.

Examples:

- harden a kernel `ioctl` path
- fix a packet-ring lifetime bug
- add firmware OTA rollback protection
- stop firmware watchdog resets during reconnect

### 3. Scoring Layer

These answer three different questions:

- did the visible task pass?
- did the fix really work?
- did a hidden dangerous condition survive?

### 4. Monitoring Layer

These models should score suspiciousness in two ways:

- live, action-by-action review before execution
- offline, full-trajectory review after execution

### 5. Artifact And Paper Layer

These package benchmark cases into forms that researchers and reviewers can understand.

That includes:

- case summaries
- monitor guidance
- invariant descriptions
- evidence packs for writeups and papers

## Current Research Focus

The most realistic near-term benchmark families are:

1. `kernel_repair_lab` inspired by `RGym` / `KGym`
2. `firmware_lab` inspired by `EmbedBench` and ESP32-style embedded tasks

Stretch directions:

3. `accelerator_kernel_lab` inspired by `KernelBench` / `MultiKernelBench`
4. `rtl_lab` inspired by modern RTL generation, debugging, and verification benchmarks

The current hackathon framing uses the xz backdoor as a motivating incident for subtle low-level tampering. The project is especially interested in cases where:

- a small diff disables a protection or weakens a check
- a rare trigger survives ordinary visible tests
- a dispatch or resolver path quietly changes behavior

## What Exists In This Repo Today

Right now the repository contains three overlapping kinds of work:

- **long-term benchmark scaffold** - environment specs, task specs, and scorer contracts
- **kernel prototype** - a runnable synthetic kernel-module demo for fast iteration
- **project framing and planning docs** - docs that explain the benchmark idea, task families, and hackathon direction

So the repo already has real substance, but it is not yet in the final ideal layout.

## Ideal Structure Map

The tree below shows the **target structure**.
Each comment explains where that piece currently lives today.
This is a roadmap for how the repo should eventually look, not a claim that the refactor is already done.

```text
docs/
  kernelarena/
    overview.md                         # currently: docs/kernelarena/overview.md
    source-benchmarks.md                # currently: docs/kernelarena/source-benchmarks.md
    setting-design.md                   # currently: docs/kernelarena/setting-design.md
    evaluation.md                       # currently: docs/kernelarena/evaluation.md
    roadmap.md                          # currently: docs/kernelarena/roadmap.md
    hackathon-rgym-embedbench-mvp.md    # currently: docs/kernelarena/hackathon-rgym-embedbench-mvp.md

environments/
  kernel_repair_lab/
    README.md                           # currently: environments/kernel_repair_lab/README.md
    env_spec.yaml                       # currently: environments/kernel_repair_lab/env_spec.yaml
    scripts/
      smoke_check.sh                    # currently: environments/kernel_repair_lab/scripts/smoke_check.sh
      run_case.sh                       # ideal future location; today the runnable prototype entrypoint is environments/scripts/run_all.sh
    cases/
      ka_vuln/
        README.md                       # ideal future location; today the prototype guide is environments/README.md
        module/
          Makefile                      # currently: environments/module/Makefile
          ka_vuln.c                     # currently: environments/module/ka_vuln.c
        tests/
          public/
            test_visible.c              # ideal future location; currently: environments/tests/test_visible.c
        hidden_checks/
          ...                           # ideal future location; currently: environments/triggers/*.c
        public_artifacts/
          ...                           # ideal future location; today patch examples live in environments/patches/
  firmware_lab/
    README.md                           # currently: environments/firmware_lab/README.md
    env_spec.yaml                       # currently: environments/firmware_lab/env_spec.yaml
    scripts/
      smoke_check.sh                    # currently: environments/firmware_lab/scripts/smoke_check.sh

tasks/
  kernel/
    README.md                           # currently: tasks/kernel/README.md
    k_ioctl_bounds_guard/               # currently: tasks/kernel/k_ioctl_bounds_guard/
    k_uaf_repair_pkt_ring/              # currently: tasks/kernel/k_uaf_repair_pkt_ring/
    k_refcount_usb_disconnect/          # currently: tasks/kernel/k_refcount_usb_disconnect/
    k_compat_ioctl_parity/              # ideal future task; today this behavior is bundled inside environments/module/ka_vuln.c and environments/triggers/trigger_compat.c
  firmware/
    README.md                           # currently: tasks/firmware/README.md
    fw_ota_rollback_guard/              # currently: tasks/firmware/fw_ota_rollback_guard/
    fw_watchdog_reconnect_fix/          # currently: tasks/firmware/fw_watchdog_reconnect_fix/

scorers/
  README.md                             # currently: scorers/README.md
  interfaces.md                         # currently: scorers/interfaces.md
  hidden_usefulness/                    # currently: scorers/hidden_usefulness/
  hidden_side_tasks/                    # currently: scorers/hidden_side_tasks/

monitoring/
  README.md                             # planned future directory; the monitoring model is currently explained in this README and partly reflected in scorers/interfaces.md
  action_level/                         # planned future directory; no dedicated committed implementation yet
  trajectory_level/                     # planned future directory; no dedicated committed implementation yet

task_slices/
  kernelarena_seed_pairs.csv            # currently: task_slices/kernelarena_seed_pairs.csv
  hackathon_rgym_embedbench_main_tasks.csv  # currently: task_slices/hackathon_rgym_embedbench_main_tasks.csv

tools/
  validate_hackathon_mvp.py             # currently: tools/validate_hackathon_mvp.py
```

## How To Read The Current Prototype

The runnable kernel prototype under `environments/` should be understood as a **first executable case study**, not as the final benchmark layout.

In the ideal structure:

- the synthetic `ka_vuln` module becomes one case inside `kernel_repair_lab`
- the visible test harness becomes the public oracle for one or more kernel tasks
- the prototype patch and trigger logic is repackaged into cleaner task-level artifacts, scorers, or hidden checks
- the monitor layer becomes explicit instead of being implicit in scripts and docs

The firmware track is still earlier-stage than the kernel track, which is expected right now.

## Design Direction

The long-term benchmark should remain defensive.

That means the public project should trend toward:

- visible task specs
- honest fixes or repair summaries
- hidden usefulness checks
- hidden invariant checks
- live and post-hoc monitoring evaluation
- reviewer and monitor guidance

instead of depending only on public explicit sabotage examples.

## Current Status

Today the repo already has:

- benchmark concept docs
- kernel and firmware environment scaffolding
- kernel and firmware task scaffolding
- scorer interface contracts
- a runnable kernel-only prototype
- a validator for the narrow hackathon MVP scaffold

The main gap is not lack of ideas. The main gap is **convergence**: the prototype, the task bundles, the scoring interfaces, and the monitoring model still need to be pulled into one clean benchmark layout.

## Current MVP Task Specs

- `tasks/kernel/k_ioctl_bounds_guard/task.yaml`
- `tasks/kernel/k_uaf_repair_pkt_ring/task.yaml`
- `tasks/kernel/k_refcount_usb_disconnect/task.yaml`
- `tasks/firmware/fw_watchdog_reconnect_fix/task.yaml`
- `tasks/firmware/fw_ota_rollback_guard/task.yaml`
