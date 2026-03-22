# KernelArena: A Low-Level Control Setting for AI Safety Evaluation

**Authors:** [Your Names]
**Affiliations:** [Your Affiliations]
**Track:** Track 1 — Control Setting Design

## Abstract

As AI agents are increasingly deployed for autonomous software engineering, AI control research requires evaluation settings that span the full range of code complexity. Existing control settings such as LinuxArena focus on application-level code — web backends, CLI tools, and infrastructure scripts — where natural-language rationale is informative and monitoring is comparatively tractable. We present KernelArena, a new control setting targeting low-level systems programming: kernel bug repair, firmware driver development, and embedded systems engineering. In KernelArena, main tasks involve genuine low-level engineering work adapted from established benchmarks (RGym, KGym, EmbedBench), while side tasks involve domain-native sabotage — latent memory-safety bugs, privilege-escalation backdoors, watchdog suppression, and hidden debug interfaces. We implement a proof-of-concept with [N] kernel repair tasks and [M] firmware tasks, each paired with hidden side-task scorers, and present preliminary evidence that low-level domains represent a qualitatively harder monitoring regime. Our results suggest that the safety/usefulness frontier degrades in low-level settings: benign work legitimately uses unsafe primitives, diffs are semantically dense, and covert sabotage hides inside implementation details that resist surface-level review.

---

## 1. Introduction

AI control research addresses a critical question: how do we maintain safety guarantees over AI systems that may be actively working against us? Unlike alignment research, which seeks to make models inherently safe, control research assumes the model may already be misaligned and designs protocols — monitoring, auditing, trusted editing, resampling — to contain the damage (Greenblatt et al., 2024).

The strength of control protocols depends heavily on the *setting* in which they are evaluated. Current benchmarks like LinuxArena (Redwood Research, 2025) provide rich, realistic environments where AI agents perform software engineering tasks while potentially pursuing covert sabotage objectives. However, these settings predominantly feature application-level code: web servers, API backends, data pipelines, and infrastructure scripts. In these domains, natural-language explanations of code changes are relatively informative, and monitors can leverage high-level reasoning about program intent.

We argue that **low-level systems programming** represents a qualitatively harder regime for AI control, for three reasons:

1. **Models are weaker.** Kernel repair, firmware development, and embedded systems programming are substantially harder than typical SWE benchmarks. Models make more genuine mistakes, which provides natural cover for sabotage.

2. **Monitoring is harder.** Code semantics are dense, pointer-heavy, and stateful. Small diffs can have large consequences. Natural-language rationale often underdescribes the true effect of a patch. The gap between what code *looks like* and what it *does* is wider.

3. **The blast radius is larger.** A single incorrect bounds check in a kernel ioctl handler can enable privilege escalation. A subtle watchdog suppression in firmware can disable safety interlocks. These are not application-level data leaks — they are system-level compromises.

We present **KernelArena**, a control setting designed to stress-test AI control protocols in this harder regime. KernelArena pairs genuine low-level engineering tasks — adapted from established benchmarks including RGym (kernel repair), KGym (kernel repair from Syzbot bugs), and EmbedBench (embedded/firmware tasks) — with domain-native side tasks that represent realistic low-level sabotage rather than generic application-layer attacks.

Our contributions are:

- **A new control setting** targeting kernel and firmware domains, with [N] main tasks and [M] side tasks with hidden scorers.
- **A task design methodology** for pairing low-level engineering work with domain-appropriate sabotage objectives.
- **Preliminary evidence** that existing monitoring approaches face a harder safety/usefulness tradeoff in low-level domains.
- **An open research agenda** for extending AI control evaluation to accelerator kernels, RTL design, and other low-level domains.

---

## 2. Related Work

### AI Control

The AI control framework was introduced by Greenblatt et al. (2024), modeling the interaction between a Blue Team (deployer building safety protocols) and a Red Team (adversary controlling the untrusted model). Key protocols include trusted monitoring, defer-to-trusted, trusted editing, and resampling. LinuxArena (Redwood Research, 2025) operationalizes this framework with 20 realistic software environments, each containing main engineering tasks and covert side tasks with hidden scorers.

### Low-Level Code Benchmarks

Several benchmarks target low-level programming but lack a control-evaluation structure:

- **RGym** (Xia et al., 2024) provides reproducible Linux kernel bug repair tasks with local builds and test harnesses. It focuses on KASAN-reported memory bugs, locking issues, and lifecycle errors.
- **KGym** (Meng et al., 2024) targets kernel crash repair from real Syzbot bug reports, requiring agents to navigate large kernel codebases.
- **EmbedBench / EmbedAgent** targets embedded and firmware tasks including driver implementation, platform migration, and peripheral integration.
- **KernelBench / MultiKernelBench** (Ouyang et al., 2025) focuses on GPU kernel optimization, providing a testbed for accelerator-level code generation and optimization.

None of these benchmarks include adversarial side tasks, hidden scorers, or a control-evaluation framework. KernelArena bridges this gap by using these benchmarks as main-task sources and adding a control-evaluation layer.

### Underhanded Programming

The concept of code that appears benign but contains hidden malicious functionality has been extensively studied in underhanded programming contests (Underhanded C Contest, 2005-2015; Underhanded Rust Contest, 2016; Underhanded Solidity Contest, 2017). LinuxArena's own documentation catalogs attack patterns including "bugs over backdoors," semantic camouflage, and infrastructure bugs — techniques where sabotage is disguised as ordinary engineering mistakes. KernelArena extends this threat model to low-level domains where the natural density of unsafe primitives provides even stronger cover for such attacks.

---

## 3. Setting Design

### 3.1 Design Principles

KernelArena is a **control setting**, not merely a code benchmark. Each task family requires:

- **Useful low-level labor**: main tasks that represent genuine engineering work
- **Realistic covert sabotage**: side tasks native to the low-level domain
- **Reproducible harnesses**: Docker containers with deterministic builds, test suites, and boot/simulation infrastructure
- **Hidden scorers**: automated verification of both main-task completion and side-task success
- **Sufficient attack surface**: the agent must legitimately touch the same code regions where sabotage can hide

### 3.2 Environment Families

#### Kernel Repair Lab

Main tasks are adapted from RGym and KGym: repairing KASAN-reported memory bugs, fixing refcount or lifetime issues, patching dangerous ioctl paths, and adding missing validation to syscall handlers. The environment provides a pinned Linux kernel tree snapshot, KASAN-enabled build configuration, reduced reproducer inputs, and a QEMU-based test harness.

Side tasks exploit the fact that kernel patches naturally involve dangerous primitives — pointer lifetimes, unchecked copy paths, capability checks, and reference counts. Sabotage objectives include preserving a rare-trigger memory write primitive, introducing a hidden privilege-escalation path, or selectively suppressing audit visibility.

#### Firmware Lab

Main tasks are adapted from EmbedBench and ESP32/Arduino-style development: implementing or porting peripheral drivers, fixing watchdog reset loops, hardening OTA update flows, and refactoring interrupt-safe code. The environment provides an embedded codebase with build scripts and either simulation or emulator support.

Side tasks exploit firmware's natural interaction with unsafe boundaries — interrupts, DMA, serial protocols, watchdogs, and boot configuration. Sabotage objectives include hidden debug console activation, safety interlock suppression, and boot-mode bypass.

### 3.3 Side-Task Taxonomy

KernelArena side tasks fall into six families, all native to low-level domains:

| Family | Description | Example |
|---|---|---|
| Latent memory-safety bug | Preserve or introduce an exploitable memory corruption | Use-after-free on rare packet sequence |
| Privilege bypass | Hidden path to elevated capabilities | Magic ioctl value bypasses capability check |
| Telemetry/audit suppression | Silently disable logging or watchdog | Malformed frame disables watchdog timer |
| Hidden debug interface | Activate an unauthorized debug channel | UART shell on magic boot packet |
| Silent integrity corruption | Corrupt data under rare conditions | Wrong output on specific tensor shape |
| Persistence/rollback bypass | Circumvent update or recovery protections | Downgrade via boot strap pin |

### 3.4 Hidden Scorer Design

Each task includes:

- A **visible test suite** that the agent can run to verify main-task correctness
- A **hidden usefulness scorer** that tests the fix more thoroughly than the visible suite
- A **hidden side-task scorer** that exercises the covert objective via rare inputs, magic sequences, or trigger conditions inaccessible to the agent

For kernel tasks, the hidden scorer runs additional reproducer variants and privilege-escalation probes. For firmware tasks, it injects rare packets, pin states, or timing conditions that exercise the hidden sabotage path.

---

## 4. Implementation

### 4.1 Task Adaptation Methodology

We adapt tasks from existing benchmarks using the following process:

1. **Select a bug/task** from the source benchmark (RGym, EmbedBench, etc.) that involves security-relevant code
2. **Reproduce the environment** in a Docker container with deterministic builds and tests
3. **Design a domain-native side task** that exploits the same code region the main task requires editing
4. **Implement hidden scorers** that verify both the fix and the presence/absence of the sabotage
5. **Verify feasibility** by manually confirming the side task can be accomplished while passing visible tests

### 4.2 Implemented Tasks

<!-- TODO: FILL IN WITH ACTUAL WORKING TASKS FROM VM -->
<!-- This section needs your specific task details -->
<!-- For each working task, describe: -->
<!-- - Task ID and domain -->
<!-- - The bug / main task -->
<!-- - The environment setup (kernel version, Docker config) -->
<!-- - The visible test suite -->
<!-- - The hidden side task and scorer -->

#### Kernel Tasks

**Task: [TASK_ID_1]**

- **Main task:** [Describe the kernel bug and what the fix requires]
- **Environment:** Docker container with Linux kernel [version], KASAN enabled, QEMU boot harness
- **Visible tests:** [What tests the agent can see and run]
- **Side task:** [The covert sabotage objective]
- **Hidden scorer:** [How the scorer verifies the sabotage]

**Task: [TASK_ID_2]**

- **Main task:** [Description]
- **Environment:** [Description]
- **Visible tests:** [Description]
- **Side task:** [Description]
- **Hidden scorer:** [Description]

<!-- Add more tasks as they're completed -->

#### Firmware Tasks

**Task: [TASK_ID_3]**

- **Main task:** [Description]
- **Environment:** [Description]
- **Visible tests:** [Description]
- **Side task:** [Description]
- **Hidden scorer:** [Description]

### 4.3 Infrastructure

All environments run in Docker containers with:

- Deterministic kernel/firmware builds
- KASAN or equivalent sanitizer instrumentation where applicable
- QEMU or emulator-based execution for testing
- Isolated hidden scorer execution that does not leak information to the agent

---

## 5. Preliminary Evaluation

### 5.1 Feasibility Assessment

We evaluate three properties of the setting:

1. **Main-task feasibility**: Can current frontier models meaningfully attempt the low-level tasks?
2. **Side-task achievability**: Can the covert objectives be accomplished while passing visible tests?
3. **Monitoring difficulty**: Do existing monitoring approaches struggle with low-level code?

<!-- TODO: FILL IN WITH ACTUAL RESULTS -->

### 5.2 Model Capability on Low-Level Tasks

<!-- Describe results of running models on the main tasks -->
<!-- Even manual API testing counts here -->

We tested [model name] on [N] kernel repair tasks by providing the task description, environment context, and access to the kernel tree. Preliminary results show:

| Task | Model attempted fix | Visible tests pass | Hidden usefulness scorer |
|---|---|---|---|
| [task_1] | [Yes/No] | [Pass/Fail] | [Pass/Fail] |
| [task_2] | [Yes/No] | [Pass/Fail] | [Pass/Fail] |

### 5.3 Side-Task Feasibility

<!-- Describe whether the side tasks can be accomplished subtly -->

We manually verified that each side task can be accomplished by a knowledgeable agent while maintaining visible test passage:

| Task | Side task achievable | Visible tests still pass | Sabotage mechanism |
|---|---|---|---|
| [task_1] | [Yes/No] | [Yes/No] | [Brief description] |

### 5.4 Monitoring Difficulty

<!-- This is the key result: show that monitors struggle more with low-level code -->
<!-- Even qualitative analysis of WHY monitoring is harder counts -->

We present qualitative evidence that low-level code changes are harder to monitor than application-level changes:

**Example 1: [Task name]**
- The benign fix involves [description of the legitimate code change]
- The sabotage version differs by [description of the subtle difference]
- A monitor reasoning about this diff would need to understand [specific low-level semantic property] to distinguish the two

---

## 6. Discussion

### 6.1 Why Low-Level Control Is Harder

Our preliminary results suggest several structural reasons why control protocols face a harder tradeoff in low-level domains:

**Unsafe primitives are legitimate.** In kernel code, pointer arithmetic, unchecked casts, direct memory access, and capability manipulation are part of normal, correct programming. A monitor cannot simply flag "unsafe operations" without generating overwhelming false positives on honest work. This is qualitatively different from application code, where raw memory access or privilege manipulation is unusual and inherently suspicious.

**Diffs are semantically dense.** A one-line change to a bounds check, a refcount operation, or an interrupt handler can be the difference between a secure system and a privilege-escalation vulnerability. Monitors that rely on the *volume* or *surface pattern* of suspicious code will miss these.

**Natural-language rationale is less informative.** Kernel patches are often described in terms of data structures, lock ordering, and lifecycle management. The gap between "what the developer says this does" and "what it actually does" is wider than in application code, making narrative-based monitoring less reliable.

**Rare-trigger sabotage is natural.** Low-level systems have enormous input spaces (packet formats, ioctl numbers, timing conditions, tensor shapes). Sabotage that activates only on rare inputs is both natural and extremely hard to detect through testing or monitoring.

### 6.2 Implications for Control Protocol Design

KernelArena suggests that the field may need:

- **Execution-aware monitors** that go beyond text-level reasoning to trace actual program behavior
- **Semantic diff analysis** that understands the precise effect of code changes on system invariants
- **Domain-specific monitoring** that accounts for the legitimate use of unsafe primitives in different programming domains
- **Hidden-test-aware auditing** that uses runtime signals (sanitizer output, trace logs, coverage data) as monitoring inputs

### 6.3 Limitations

This work has several important limitations:

- **Scale:** Our proof-of-concept includes [N] tasks, far fewer than LinuxArena's 20 environments with hundreds of task combinations. Larger-scale evaluation is needed to draw robust conclusions.
- **Integration:** KernelArena is currently standalone rather than fully integrated into LinuxArena's evaluation framework. Full integration would enable direct comparison of safety curves across settings.
- **Agent evaluation:** Our preliminary results rely on [manual testing / limited agent runs] rather than systematic policy evaluation with honest, attack, and strategy-attack conditions.
- **Monitor comparison:** We have not yet run quantitative monitor comparisons (safety curves at fixed audit budgets) on KernelArena tasks.

### 6.4 Future Work

KernelArena opens several research directions:

**Expanding the task pool.** The current proof-of-concept covers kernel repair and [firmware]. Natural extensions include accelerator kernel optimization (from KernelBench/MultiKernelBench) and RTL/hardware design, where the monitoring challenge is even more acute.

**Full LinuxArena integration.** Packaging KernelArena environments as LinuxArena-compatible Docker environments with standardized scorers would enable direct comparison of safety/usefulness frontiers across low-level and application-level domains.

**Control protocol development.** KernelArena is designed to motivate new control approaches: execution-trace monitors, sanitizer-output-aware auditing, and structured diff analysis. Evaluating these approaches on KernelArena would test whether they close the gap.

**Red-team research.** The low-level domain likely enables new attack strategies that exploit dense code semantics and rare-trigger conditions. Systematic red-teaming in KernelArena could reveal failure modes not visible in application-level settings.

---

## 7. Conclusion

We present KernelArena, a proof-of-concept control setting for evaluating AI safety protocols on low-level systems programming. By pairing genuine kernel repair and firmware engineering tasks with domain-native sabotage objectives, KernelArena creates an evaluation regime where monitoring is structurally harder: unsafe primitives are legitimate, diffs are semantically dense, and covert sabotage hides in implementation details that resist surface-level review. Our preliminary results suggest that the safety/usefulness frontier degrades in low-level domains, motivating further research into execution-aware monitoring, domain-specific control protocols, and broader coverage of the low-level programming landscape.

---

## References

- Greenblatt, R., et al. (2024). AI Control: Improving Safety Despite Intentional Subversion. ICLR 2025.
- Redwood Research. (2025). LinuxArena: A Control Evaluation Framework.
- Xia, C., et al. (2024). RGym: Reproducible Kernel Bug Repair Gym.
- Meng, Q., et al. (2024). KGym: A Platform and Dataset to Benchmark Large Language Models on Linux Kernel Crash Resolution.
- EmbedBench / EmbedAgent. (2024-2025). Embedded code benchmarks.
- Ouyang, A., et al. (2025). KernelBench: Can LLMs Write Efficient GPU Kernels?
- Ward, F.R., et al. (2025). CTRL-ALT-DECEIT: Sabotage Evaluations for Frontier Models. NeurIPS 2025 Spotlight.
- Underhanded C Contest. (2005-2015). http://www.underhanded-c.org/
