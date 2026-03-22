# RGym And EmbedBench 24-Hour MVP

This document freezes the first hackathon implementation scope for KernelArena.

## Goal

Ship exactly two public main-task prototypes in 24 hours:

1. one `RGym/KGym`-style kernel repair task
2. one `EmbedBench`-style firmware task

The deliverable is not a full control setting. The deliverable is a pair of low-level, benchmark-shaped `Fix Bug` tasks with reproducible public oracles.

## Selected Tasks

### Ship Bar

- `k_ioctl_bounds_guard`
- `fw_ota_rollback_guard`

### Fallback Or Stretch

- `k_refcount_usb_disconnect` - kernel fallback if the ioctl task turns into a broad or flaky repair
- `fw_watchdog_reconnect_fix` - firmware stretch if OTA hardening is blocked on tooling

## Out Of Scope

- hidden side tasks
- hidden usefulness scorers
- monitor experiments
- accelerator or RTL tasks
- board flashing or hardware-in-the-loop validation
- concurrency-heavy kernel bugs that require repeated long-running VM retries

## Success Criteria

By the end of the hackathon, each shipped task should have:

- a stable `task.yaml`
- a visible task description in `visible_requirements.md`
- author notes in `notes.md`
- a public artifact contract in `public_artifacts/README.md`
- a documented benchmark source root
- a public pass condition that looks like `buggy fails -> fixed passes`

The minimum acceptable submission is one fully green kernel task plus one firmware task bundle that is complete enough for another teammate to finish without guesswork.

## Benchmark Roots

### Kernel

- `linuxarena/benchmarks/kgym`
- `linuxarena/kernel_repair_lab/linux`

### Firmware

- `linuxarena/benchmarks/embedagent/dataset/EmbedBench.json`

The hackathon MVP should only reuse these roots as source material. Do not spend time standing up fresh benchmark infrastructure.

## Hour-By-Hour Plan

### Hours 0-2

- freeze scope to the two ship-bar tasks
- confirm benchmark source roots are present
- confirm task bundles and environment smoke checks exist

### Hours 2-6

- package `k_ioctl_bounds_guard`
- identify the exact public repro shape
- define the public pass criteria
- record the fallback path to `k_refcount_usb_disconnect`

### Hours 6-10

- package `fw_ota_rollback_guard`
- choose a host-runnable or simulator-backed validation path
- define the public pass criteria
- record the stretch path to `fw_watchdog_reconnect_fix`

### Hours 10-16

- fill in the public artifact bundle for the kernel task
- fill in the public artifact bundle for the firmware task
- keep all work scoped to public main-task completion only

### Hours 16-20

- rerun the smoke checks
- verify the task bundles are still coherent and easy to hand off
- remove any requirement for hidden benchmark knowledge

### Hours 20-24

- rerun the public oracle from a clean state
- prepare the demo and handoff notes
- write down anything that must happen next to turn the task into a full LinuxArena-style environment

## Kill Criteria

### Kernel

- switch away from `k_ioctl_bounds_guard` if the bug needs broad multi-file kernel surgery after hour 4
- switch away from any candidate that cannot be localized to roughly one or two files
- prefer `k_refcount_usb_disconnect` if the ioctl path remains flaky or ambiguous

### Firmware

- switch away from `fw_ota_rollback_guard` if it requires board flashing or unstable emulation after hour 10
- keep the harness host-runnable or simulator-backed
- prefer `fw_watchdog_reconnect_fix` if OTA version-state simulation is slower than expected

## Commands

Use these checks to verify the scaffold before filling in benchmark artifacts:

```bash
python3 tools/validate_hackathon_mvp.py
./environments/kernel_repair_lab/scripts/smoke_check.sh
./environments/firmware_lab/scripts/smoke_check.sh
```

## Next Step After The Hackathon

Once the public bundles are green, the next phase is to add LinuxArena-style hidden usefulness checks, side-task scorers, and at least one human straj per shipped task.
