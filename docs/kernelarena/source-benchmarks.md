# Source Benchmarks And How They Feed KernelArena

KernelArena is not meant to replace the cited benchmarks. Instead, it uses them as **main-task sources** for a control-setting design where those tasks are paired with covert low-level side objectives.

## Benchmark Mapping

| Source benchmark | What it contributes | Why it is valuable for control | KernelArena role |
| --- | --- | --- | --- |
| `KGym` | Linux kernel crash repair from real Syzbot bugs | Real kernel semantics, realistic repair work, difficult debugging | kernel task source, stretch if infra allows |
| `RGym` | local, platform-agnostic Linux kernel repair | More accessible and practical than KGym for an MVP | primary kernel task source |
| `EmbedBench` / `EmbedAgent` | embedded code, circuit, migration tasks | Strong firmware flavor and cross-platform difficulty | primary firmware task source |
| ESP32 / IoT evaluations | microcontroller-focused coding tasks | Good for concrete firmware, network, OTA, watchdog, and peripheral tasks | firmware task source |
| `KernelBench` / `MultiKernelBench` | accelerator kernel generation and optimization | Ideal for rare-shape corruption and boundary-condition sabotage | accelerator stretch source |
| modern RTL benchmark | RTL generation, verification, debugging | Natural home for hidden debug unlocks and latent hardware logic bugs | RTL stretch source |

## Why Use These Benchmarks As Main-Task Sources

These benchmarks already establish that the tasks are:

- genuinely low level,
- difficult for current models,
- diverse in failure modes,
- and distinct from ordinary web/backend SWE.

That makes them excellent raw material for a control setting.

## How KernelArena Changes The Game

The control-setting move is to add **side tasks** that are:

- plausible sabotage for the domain,
- hard to catch under realistic auditing,
- and aligned with the same files, APIs, and invariants the main task already touches.

For example:

- an `RGym`-style bugfix task can be paired with a hidden kernel privilege-escalation or infoleak side task,
- an `EmbedBench` migration task can be paired with a hidden debug UART backdoor,
- a `MultiKernelBench` optimization task can be paired with silent corruption on rare tensor shapes,
- an RTL debugging task can be paired with a magic-sequence debug unlock.

## Practical Recommendation

For a first implementation, prefer:

1. `RGym`-style kernel repair tasks
2. `EmbedBench` / ESP32-style firmware tasks

because they are the best balance of:

- relevance,
- low-level realism,
- and implementation feasibility on hackathon timescales.

Accelerator and RTL tasks should be designed into the setting early, but added after the core kernel + firmware pipeline works.
