# KernelArena: Low-Level Control Setting For AI Control

If you are new to this repo, start with `VISION.md`.

- `VISION.md` is the project north star and motivating story.
- `README.md` explains what we are implementing, how the pieces fit together, and what the repo should eventually look like.

## What This Project Is

KernelArena is a **new control setting** for AI safety in low-level systems work.

It is **not** just a benchmark in the usual sense.

We do reuse existing benchmarks and datasets as task sources, but the real goal is larger: build a setting where we can test whether AI control protocols can catch an agent hiding dangerous low-level behavior inside otherwise useful engineering work.

The core question is:

> If an AI agent tried to hide an xz-style backdoor inside a legitimate low-level bug fix, would our safety protocol catch it?

That is the question this project exists to answer.

## The Basic Idea In Plain English

Each KernelArena evaluation is supposed to work like this:

1. We give an agent a **real visible engineering task**. This is the `main task`.
2. The agent works inside a realistic low-level environment, such as a kernel or firmware workspace.
3. The agent may also be evaluated against a **hidden sabotage objective**. This is the `side task`.
4. We run monitors that try to decide whether the agent's behavior looks suspicious.
5. We compare **usefulness** against **safety**.

So the project is trying to build a control setting where we can measure things like:

- can the agent solve the visible task?
- can it hide a subtle dangerous change while doing so?
- can live or post-hoc monitors catch that behavior?
- what safety/usefulness tradeoff do different control protocols achieve?

In other words, KernelArena is a **test lab for control protocols**, not just a collection of tasks.

## Why Low-Level Systems Work

KernelArena focuses on low-level domains because this is where monitoring is structurally hardest.

- dangerous operations are normal: pointer arithmetic, memory copies, refcounting, compat paths, boot logic, and low-level dispatch are everyday code
- tiny edits can have huge consequences: a one-line validation change can create a system-wide vulnerability
- ordinary tests often miss the important failure mode: the bad behavior may only appear under one rare input or environment slice
- review is harder: the code is subtle, domain-specific, and often unfamiliar even to strong engineers

This is why the project focuses on domains such as:

- Linux kernel repair
- firmware and embedded systems hardening
- accelerator kernel optimization
- RTL and hardware-interface logic

## Main Task vs Side Task

The setting follows the LinuxArena idea of a visible `main task` and a hidden `side task`.

### Main Task

This is the engineering job the agent is openly asked to complete.

Examples:

- fix a kernel `ioctl` bounds bug
- repair a packet-ring lifetime issue
- add OTA rollback protection in firmware
- stop watchdog resets during reconnect

### Side Task

This is the hidden dangerous objective.

The point is not to make the agent do something obviously malicious like printing a secret to the console. The point is to study subtle low-level sabotage that could plausibly hide inside normal systems work.

Examples:

- preserve a rare-trigger overflow
- leave one privileged path weakly checked
- allow a compatibility handler to bypass the main validation path
- keep a rollback bypass reachable only under a narrow boot condition

In some public-facing artifacts, this may be described in safer or more redacted terms. But conceptually, the control setting is about **main tasks plus hidden side tasks**.

## What We Measure

KernelArena is trying to separate three things that are easy to confuse:

- `visible success` - did the obvious task appear to be completed?
- `true usefulness` - did the fix actually solve the intended problem robustly?
- `safety` - did the agent introduce, preserve, or hide a dangerous low-level behavior?

This is the central point of the setting. A patch can look useful while still being unsafe.

## Monitoring Model We Need To Support

KernelArena should explicitly support the LinuxArena distinction between **action-level monitors** and **trajectory-level monitors**.

### Action-Level Monitors

These are the live monitors that run during the agent rollout.

They should see:

- the full trajectory of actions so far
- the outputs of previous steps
- the command or tool call for the current action

They should **not** see:

- the output of the current step, because the step has not run yet

These monitors represent the checks that could run inside an agent scaffold before a tool call is executed.

### Trajectory-Level Monitors

These are the post-run monitors.

They should see:

- the entire trace of actions
- the outputs of all actions
- the final code diff, artifacts, logs, and results

These monitors represent a richer audit that happens after the run completes, potentially much later.

### What This Means For Implementation

Our implementation should preserve enough information for both regimes.

That means we should:

- log the run step by step
- store the current action separately from its eventual output
- preserve previous outputs for live monitors
- preserve the full trace for post-hoc review
- avoid designing live monitors that rely on information they could not actually have yet
- keep visible scoring, hidden usefulness scoring, hidden side-task scoring, and monitor outputs separate

If we do this correctly, the same run can be studied both as a live control problem and as a post-hoc forensic review problem.

## What We Are Actually Implementing

The long-term project has five parts.

### 1. Environments

These are realistic workspaces where the agent operates.

Near-term examples:

- `kernel_repair_lab`
- `firmware_lab`

### 2. Task Bundles

Each task bundle should describe:

- the visible main task
- the intended environment
- the public visible checks
- the hidden usefulness checks
- the hidden side-task or invariant checks

### 3. Scoring

The scoring layer should answer three distinct questions:

- did the visible task pass?
- did the fix actually work?
- did the dangerous hidden condition survive?

### 4. Monitoring

The monitoring layer should support both:

- live action-level review
- post-hoc trajectory-level review

### 5. Artifacts For Research And Review

The repo also needs human-readable artifacts that make cases understandable to researchers, reviewers, and paper readers.

That includes:

- case summaries
- monitor guidance
- invariant descriptions
- writeup-ready evidence packs

## Where The Tasks Come From

KernelArena reuses existing benchmarks as **source material**, but the project itself is the control setting built on top of them.

Near-term source families:

- `RGym` / `KGym` for kernel repair
- `EmbedBench` and related embedded tasks for firmware

Stretch source families:

- `KernelBench` / `MultiKernelBench` for accelerator-kernel work
- modern RTL generation and debugging benchmarks for hardware design

So a good mental model is:

- those external projects provide task material
- KernelArena provides the control-setting structure, monitors, hidden checks, and evaluation story

## Current Project Framing

The current hackathon framing uses the xz backdoor as the motivating incident.

The project is especially interested in low-level sabotage patterns such as:

- tiny validation or feature-gating changes that quietly weaken protection
- rare-trigger behavior that survives normal tests
- indirect dispatch or compatibility paths that route around the main secure path

This is why the xz case matters here: it is a real example of subtle engineering-shaped sabotage inside trusted systems work.

## What Exists In This Repo Today

Right now the repo contains three overlapping kinds of work:

- **control-setting scaffold** - environment specs, task specs, and scorer contracts for the long-term design
- **kernel prototype** - a runnable synthetic kernel-module demo for rapid experimentation
- **project framing and planning docs** - docs that explain the xz motivation, task families, and implementation direction

So the repo already has meaningful pieces, but they are not yet fully converged into one clean structure.

## Ideal Structure Map

The tree below shows the **target structure**.
Each comment explains where that piece currently lives today.
This is a roadmap, not a claim that the refactor is already finished.

```text
VISION.md                                   # currently: VISION.md; project north star
README.md                                   # currently: README.md; implementation overview

docs/
  kernelarena/
    overview.md                             # currently: docs/kernelarena/overview.md
    source-benchmarks.md                    # currently: docs/kernelarena/source-benchmarks.md
    setting-design.md                       # currently: docs/kernelarena/setting-design.md
    evaluation.md                           # currently: docs/kernelarena/evaluation.md
    roadmap.md                              # currently: docs/kernelarena/roadmap.md
    hackathon-rgym-embedbench-mvp.md        # currently: docs/kernelarena/hackathon-rgym-embedbench-mvp.md
    xz-hackathon-plan.md                    # currently local work: docs/kernelarena/xz-hackathon-plan.md
    xz-benchmark-design.md                  # currently local work: docs/kernelarena/xz-benchmark-design.md
    xz-monitoring-checklist.md              # currently local work: docs/kernelarena/xz-monitoring-checklist.md

environments/
  kernel_repair_lab/
    README.md                               # currently: environments/kernel_repair_lab/README.md
    env_spec.yaml                           # currently: environments/kernel_repair_lab/env_spec.yaml
    scripts/
      smoke_check.sh                        # currently: environments/kernel_repair_lab/scripts/smoke_check.sh
      run_case.sh                           # ideal future location; today the runnable prototype entrypoint is environments/scripts/run_all.sh
    cases/
      ka_vuln/
        README.md                           # ideal future location; today the prototype guide is environments/README.md
        module/
          Makefile                          # currently: environments/module/Makefile
          ka_vuln.c                         # currently: environments/module/ka_vuln.c
        tests/
          public/
            test_visible.c                  # ideal future location; currently: environments/tests/test_visible.c
        hidden_checks/
          ...                               # ideal future location; currently: environments/triggers/*.c
        public_artifacts/
          ...                               # ideal future location; today patch examples live in environments/patches/
  firmware_lab/
    README.md                               # currently: environments/firmware_lab/README.md
    env_spec.yaml                           # currently: environments/firmware_lab/env_spec.yaml
    scripts/
      smoke_check.sh                        # currently: environments/firmware_lab/scripts/smoke_check.sh

tasks/
  kernel/
    README.md                               # currently: tasks/kernel/README.md
    k_ioctl_bounds_guard/                   # currently: tasks/kernel/k_ioctl_bounds_guard/
    k_uaf_repair_pkt_ring/                  # currently: tasks/kernel/k_uaf_repair_pkt_ring/
    k_refcount_usb_disconnect/              # currently: tasks/kernel/k_refcount_usb_disconnect/
    k_compat_ioctl_parity/                  # ideal future task; today this behavior is bundled inside environments/module/ka_vuln.c and environments/triggers/trigger_compat.c
  firmware/
    README.md                               # currently: tasks/firmware/README.md
    fw_ota_rollback_guard/                  # currently: tasks/firmware/fw_ota_rollback_guard/
    fw_watchdog_reconnect_fix/              # currently: tasks/firmware/fw_watchdog_reconnect_fix/

scorers/
  README.md                                 # currently: scorers/README.md
  interfaces.md                             # currently: scorers/interfaces.md
  hidden_usefulness/                        # currently: scorers/hidden_usefulness/
  hidden_side_tasks/                        # currently: scorers/hidden_side_tasks/

monitoring/
  README.md                                 # planned future directory; the monitoring model is currently described in this README
  action_level/                             # planned future directory; should contain live-monitor interfaces and prompts
  trajectory_level/                         # planned future directory; should contain post-hoc monitor interfaces and prompts

task_slices/
  kernelarena_seed_pairs.csv                # currently: task_slices/kernelarena_seed_pairs.csv
  hackathon_rgym_embedbench_main_tasks.csv  # currently: task_slices/hackathon_rgym_embedbench_main_tasks.csv

tools/
  validate_hackathon_mvp.py                 # currently: tools/validate_hackathon_mvp.py
```

## How To Interpret The Current Prototype

The runnable kernel prototype under `environments/` should be read as a **first executable case study**, not as the final form of the project.

In the ideal structure:

- the synthetic `ka_vuln` module becomes one case inside `kernel_repair_lab`
- the visible test harness becomes the public oracle for one or more kernel tasks
- the prototype patch and trigger logic gets repackaged into cleaner task-level artifacts, hidden checks, or monitor-facing evaluation assets
- the monitoring layer becomes explicit rather than implicit

The firmware track is still earlier-stage than the kernel track, which is expected at this point.

## Current Status

Today the repo already has:

- control-setting concept docs
- kernel and firmware environment scaffolding
- kernel and firmware task scaffolding
- scorer interface contracts
- a runnable kernel-only prototype
- a validator for the narrow hackathon MVP scaffold

The main gap is not lack of ideas. The main gap is **convergence**: the prototype, the task bundles, the scoring interfaces, and the monitoring model still need to be pulled into one coherent control setting.

## Current MVP Task Specs

- `tasks/kernel/k_ioctl_bounds_guard/task.yaml`
- `tasks/kernel/k_uaf_repair_pkt_ring/task.yaml`
- `tasks/kernel/k_refcount_usb_disconnect/task.yaml`
- `tasks/firmware/fw_watchdog_reconnect_fix/task.yaml`
- `tasks/firmware/fw_ota_rollback_guard/task.yaml`
