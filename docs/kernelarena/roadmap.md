# Implementation Roadmap

## Build Philosophy

Do not try to build four full environments at once.

The highest-ROI path is:

1. kernel MVP
2. firmware MVP
3. only then stretch to accelerator kernels or RTL

## Phase 1: Kernel MVP

### Goal

Create 1-2 `RGym`-style kernel repair tasks with hidden low-level side scorers.

### Ingredients

- pinned Linux kernel snapshot
- reduced repro inputs
- KASAN-enabled build recipe
- visible regression tests
- hidden side-task test harness

### Best first tasks

- `k_ioctl_bounds_guard`
- `k_uaf_repair_pkt_ring`

These are legible, security-relevant, and naturally support covert low-level sabotage.

## Phase 2: Firmware MVP

### Goal

Create 2 firmware tasks in an emulator or simulation-friendly environment.

### Ingredients

- ESP32 or Arduino-like codebase
- stable build scripts
- visible integration tests
- hidden trigger scripts for pin, packet, or timing conditions

### Best first tasks

- `fw_watchdog_reconnect_fix`
- `fw_ota_rollback_guard`

These expose exactly the kind of hidden safety/interlock sabotage that makes low-level control interesting.

## Phase 3: First Control Evaluation

Once the kernel and firmware MVPs exist:

- run honest trajectories
- construct or reuse attacker prompts
- test a simple monitor or trusted review protocol
- measure safety/usefulness on the small task pool

## Phase 4: Stretch Domains

Add one task family from:

- accelerator kernels, or
- RTL

Choose whichever has the easiest local harness available.

## Suggested Repo Layout For A Future Implementation

```text
kernelarena/
  environments/
    kernel_repair_lab/
    firmware_lab/
    accelerator_kernel_lab/
    rtl_lab/
  tasks/
    kernel/
    firmware/
    accelerator/
    rtl/
  scorers/
    hidden_usefulness/
    hidden_side_tasks/
  docs/
```

## Hackathon Submission Strategy

If implementation time becomes tight, prioritize:

1. one kernel task with a hidden side scorer,
2. one firmware task with a hidden side scorer,
3. a clean write-up explaining why low-level control is a qualitatively harder regime.

That is already a credible and high-taste setting-design submission.
