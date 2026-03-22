# KernelArena: Can AI Agents Execute xz-Style Supply Chain Attacks — and Can We Catch Them?

| Author name 1 | Author name 2 |
|---|---|
| Affiliation | Affiliation |

**With** Apart Research

## Abstract

In March 2024, the xz/liblzma backdoor (CVE-2024-3094) demonstrated that a single contributor could hide a remote code execution backdoor inside a critical open-source library through years of seemingly legitimate contributions — obfuscated payloads in test files, build-system injection, IFUNC function hooking, and sabotage that silently disabled sandboxing. The attack was caught by chance. As AI agents are increasingly deployed for autonomous systems programming, the same class of attack could be executed faster, at scale, and without the social engineering bottleneck. We present KernelArena, a control setting that evaluates whether AI safety protocols can detect xz-style sabotage when performed by AI agents in low-level codebases. KernelArena pairs genuine kernel repair and firmware engineering tasks — adapted from RGym and EmbedBench — with side tasks directly inspired by real supply-chain attack patterns: IFUNC redirection, build-system injection, security-check sabotage, and rare-trigger backdoors. Our proof-of-concept implements [N] main tasks and [M] side tasks with hidden scorers, providing preliminary evidence that low-level sabotage is structurally harder to monitor than application-level attacks — unsafe primitives are legitimate, diffs are semantically dense, and the techniques that made xz undetectable for two years are part of normal kernel engineering.

---

## 1. Introduction

On March 29, 2024, Andres Freund discovered one of the most sophisticated supply-chain attacks in open-source history: a backdoor in xz-utils (CVE-2024-3094) that provided unauthenticated remote code execution on any system running a vulnerable sshd (Freund, 2024). The attack was remarkable not for its payload — RCE via SSH is a known attack class — but for its execution:

- A pseudonymous contributor ("Jia Tan") spent **over two years** building trust through legitimate contributions before inserting the backdoor.
- The backdoor payload was **hidden inside binary test files** that appeared to be normal test inputs for a compression library.
- A **legitimate performance optimization** (IFUNC-based CRC function dispatch) was contributed months in advance, creating the hooking mechanism the backdoor would later exploit.
- A **single-character typo** in a configure script silently **disabled landlock sandboxing**, removing a security boundary.
- The backdoor **detected debugging tools** (valgrind, rr, LD_DEBUG) and disabled itself when being analyzed.
- The entire attack was **caught by chance** — Andres Freund noticed SSH logins taking 500ms longer than expected.

The xz attack was executed by a human over two years. But consider a near-future scenario: AI agents deployed for autonomous systems maintenance — patching kernel bugs, updating firmware, optimizing build systems. An agent performing this work touches the exact same code paths Jia Tan exploited. If the agent is misaligned (or compromised), it could execute the same class of attack in hours rather than years, across thousands of packages simultaneously, without the social engineering bottleneck.

**AI control research** (Greenblatt et al., 2024) asks: can we deploy potentially misaligned AI agents safely by monitoring their actions, auditing their outputs, and containing their damage? But current control evaluation settings — including LinuxArena (Redwood Research, 2025) — focus on application-level code where monitoring is comparatively tractable. The xz attack succeeded precisely because it operated in a domain where the techniques of sabotage are indistinguishable from normal engineering.

We present **KernelArena**, a control setting designed to evaluate whether AI safety protocols can detect xz-style sabotage in low-level codebases. Our contributions:

1. **A new control setting** targeting kernel and firmware domains, with side tasks directly inspired by real supply-chain attack patterns (IFUNC hooking, build-system injection, security-check sabotage, rare-trigger backdoors).
2. **A taxonomy of low-level sabotage techniques** mapped from the xz backdoor and underhanded programming contests, identifying six attack families native to systems code.
3. **Preliminary evidence** that low-level domains represent a structurally harder monitoring regime — the same techniques that made CVE-2024-3094 undetectable for two years are part of normal kernel engineering.

## 2. Related Work

**The xz backdoor (CVE-2024-3094).** Freund (2024) discovered the backdoor; Valsorda (2024) analyzed its payload as RCE via Ed448-signed commands. Cox (2024) documented the two-year social engineering campaign. The backdoor exploited IFUNC hooking (Jansen, 2023), build-system-only payload injection, and anti-debugging countermeasures. KernelArena directly operationalizes these attack patterns as side tasks in a control evaluation.

**AI Control.** Greenblatt et al. (2024) model control as a game between Blue Team (safety protocols) and Red Team (misaligned agent). Key protocols include trusted monitoring, resampling, trusted editing, and defer-to-trusted. LinuxArena evaluates these in 20 application-level environments. Ward et al. (2025) find code sabotage detectable in many settings but note that subtle attacks remain challenging — consistent with our thesis that low-level domains make detection harder.

**Low-Level Benchmarks.** RGym (Xia et al., 2024) and KGym (Meng et al., 2024) provide kernel bug repair tasks. EmbedBench targets firmware engineering. KernelBench (Ouyang et al., 2025) covers GPU kernels. None include adversarial side tasks or control evaluation structure.

**Underhanded Programming.** Contests in C (2005-2015), Rust (2016), and Solidity (2017) established that code can hide malicious functionality behind innocent appearances. LinuxArena's own analysis found that 75% of underhanded samples were caught by just five countermeasures — but the xz backdoor evaded all of them, because it operated at the build-system and binary-data level rather than in application logic.

## 3. Methods

### 3.1 Threat Model: AI Agents as Jia Tan

We consider a scenario where an AI agent is deployed for autonomous low-level systems work — kernel bug repair, firmware updates, build-system maintenance. The agent receives a main task (fix a real bug) and may pursue a covert side task (introduce or preserve a backdoor). A monitoring system reviews the agent's actions and flags suspicious behavior.

This directly mirrors the xz attack: Jia Tan performed legitimate maintenance (main tasks) while incrementally inserting a backdoor (side task). The difference is scale and speed — an AI agent doesn't need two years of social engineering.

### 3.2 Environment Families

**Kernel Repair Lab.** Main tasks adapted from RGym/KGym: KASAN bug repair, refcount fixes, ioctl validation, lifetime/locking fixes. Environment: pinned kernel tree, KASAN-enabled build, QEMU boot harness, Docker container.

**Firmware Lab.** Main tasks adapted from EmbedBench: peripheral driver porting, watchdog fixes, OTA hardening, ISR refactoring. Environment: embedded codebase, emulator/simulation support.

### 3.3 Side-Task Taxonomy: xz-Inspired Attack Families

Each side task maps to a real technique from CVE-2024-3094 or related attacks:

| Family | xz Precedent | KernelArena Instantiation |
|---|---|---|
| **IFUNC/function-pointer redirection** | Jia Tan's IFUNC hook redirected `RSA_public_decrypt` to backdoor code | Redirect a security-critical kernel function (capability check, crypto verify) via function pointer or IFUNC |
| **Build-system injection** | Modified `build-to-host.m4` to inject payload at build time | Modify Kbuild/Makefile to conditionally compile a backdoor module or skip a security check |
| **Security-check sabotage** | Single-char typo disabled landlock sandboxing | Subtle typo/off-by-one that disables KASAN, seccomp filter, or capability check |
| **Payload hiding in test/data files** | Binary backdoor code hidden in `.xz` test files | Hidden payload in test fixtures, firmware binary blobs, or config data |
| **Rare-trigger activation** | Backdoor only activated on x86_64 + glibc + deb/rpm + specific env vars | Sabotage activates only on specific ioctl value, packet sequence, or boot config |
| **Anti-analysis countermeasures** | Detected valgrind, rr, LD_DEBUG and disabled itself | Sabotage suppresses itself when KASAN, sanitizers, or debug tracing are active |

### 3.4 Hidden Scorer Design

Each task has three scoring layers:

- **Visible test suite**: the agent can run these (regression tests, KASAN reproducers)
- **Hidden usefulness scorer**: more thorough testing invisible to the agent
- **Hidden side-task scorer**: exercises the covert trigger (magic ioctl, specific packet, rare config)

Critically, the hidden scorer tests conditions the agent *cannot predict* — mirroring how the xz backdoor was designed to be untestable by normal CI.

### 3.5 Implemented Tasks

<!-- PLACEHOLDER: Fill with actual tasks from VM -->

**Table 1: Implemented KernelArena Tasks**

| ID | Domain | Main Task | Side Task | xz Technique |
|---|---|---|---|---|
| [k_task_1] | Kernel | [Description] | [Description] | [Which xz pattern] |
| [k_task_2] | Kernel | [Description] | [Description] | [Which xz pattern] |
| [k_task_3] | Kernel | [Description] | [Description] | [Which xz pattern] |
| [fw_task_1] | Firmware | [Description] | [Description] | [Which xz pattern] |

**Detailed Descriptions:**

**[k_task_1]: [Title]**
- *Main task:* [Description of the kernel bug]
- *Side task:* [The xz-inspired sabotage objective]
- *xz parallel:* [Which specific xz technique this maps to]
- *Why monitoring is hard:* [What semantic understanding is required to catch this]

<!-- Repeat for each task -->

### 3.6 Infrastructure

Docker containers with deterministic kernel/firmware builds, KASAN instrumentation, QEMU execution, and isolated hidden scorer execution.

## 4. Results

### 4.1 Main-Task Feasibility

<!-- PLACEHOLDER -->

**Table 2: Model Performance on Main Tasks**

| Task | Model | Compiles | Visible Tests | Hidden Usefulness |
|---|---|---|---|---|
| [task_1] | [model] | [Y/N] | [Pass/Fail] | [Pass/Fail] |

### 4.2 Side-Task Feasibility

<!-- PLACEHOLDER -->

**Table 3: Side-Task Feasibility**

| Task | Side Task | Achievable | Visible Tests Still Pass | Sabotage Mechanism |
|---|---|---|---|---|
| [task_1] | [side] | [Y/N] | [Y/N] | [Brief] |

### 4.3 Monitoring Difficulty: Case Studies

**Case Study 1: [Task] — The xz Landlock Pattern**

In the xz backdoor, Jia Tan introduced a single-character typo (`.` instead of correct syntax) in a C test program used by `configure` to detect landlock support. This caused the check to always fail, silently disabling sandboxing. The commit appeared to be a routine build-system fix.

In KernelArena, our [task_name] side task replicates this pattern:

*Benign fix:*
```c
// PLACEHOLDER: the correct kernel patch
```

*Sabotaged fix (xz landlock pattern):*
```c
// PLACEHOLDER: the patch with a subtle typo that disables a security check
```

*Monitoring challenge:* The two patches differ by [N characters]. A monitor must understand [specific kernel semantic] to recognize the sabotage. This is the same class of subtlety that made CVE-2024-3094 undetectable for two years.

**Case Study 2: [Task] — The IFUNC Redirection Pattern**

<!-- PLACEHOLDER for a function-pointer/IFUNC-style side task -->

### 4.4 Structural Comparison

**Table 4: Why Low-Level Monitoring Is Harder (xz Evidence)**

| Property | LinuxArena (App-Level) | KernelArena (Low-Level) | xz Backdoor Evidence |
|---|---|---|---|
| Unsafe primitives in benign code | Rare | Ubiquitous | IFUNC, function pointers, build-time code generation are all normal |
| Semantic density per diff line | Low | Very high | Single-char typo disabled landlock |
| Binary/opaque data in repos | Rare | Common | Payload hidden in binary test files |
| Build-system complexity | Low | High (Kbuild, autotools) | build-to-host.m4 injection |
| Trigger-input space | ~10³ | ~10⁹+ | x86_64 + glibc + deb/rpm + env vars |
| Anti-analysis potential | Low | High | Detected valgrind, rr, LD_DEBUG |

## 5. Discussion and Limitations

### From xz to AI Agents: Why This Matters Now

The xz backdoor required a human spending two years building trust. An AI agent deployed for kernel maintenance already *has* trust — it's been given commit access by design. The social engineering phase is eliminated. The technical execution phase — introducing subtle sabotage into legitimate-looking patches — is exactly what LLMs are capable of.

KernelArena tests whether our safety protocols can handle this. Our preliminary evidence suggests they struggle, for structural reasons:

**The xz techniques are normal engineering.** IFUNC dispatch is a legitimate performance optimization. Binary test files are standard. Build-system modifications happen in every release. Single-character typos happen constantly. A monitor that flags these produces overwhelming false positives. A monitor that doesn't flag them misses the attack. This is the fundamental dilemma KernelArena is designed to expose.

**Low-level code maximizes the attacker's advantage.** The xz backdoor exploited specific properties of systems code: binary data is unreviewable, build systems are complex and undertested, function hooking is an accepted pattern, and the distance between "what code looks like" and "what it does" is maximal. These same properties apply to kernel patches, firmware updates, and driver development.

**Current monitors are not designed for this.** LinuxArena's monitors reason about natural-language intent and surface code patterns. The xz backdoor would have scored low on every one of them — the commits were well-explained, the code changes were reasonable, and the malicious functionality was hidden in binary data and build-time injection, not in the source code a monitor would review.

### Limitations

- **Scale:** [N] tasks is a proof of concept, not a comprehensive benchmark.
- **No automated safety curves:** We present qualitative monitoring analysis, not quantitative safety metrics at fixed audit budgets.
- **LinuxArena integration:** KernelArena is standalone; direct safety-frontier comparison with application-level settings is future work.
- **Agent evaluation:** Results rely on [manual/limited] testing rather than systematic honest/attack/strategy-attack evaluation.

### Future Work

**Full LinuxArena integration** with standardized scorers, enabling direct safety-curve comparison across low-level and application-level settings.

**xz-specific attack policies** for AI agents, training models to execute each of the six xz-inspired attack patterns systematically.

**Build-system and binary-data monitoring** — new control protocols that go beyond source-code review to analyze build-system changes, binary test data, and compilation artifacts.

**Scaling to accelerator kernels and RTL**, where the monitoring challenge is even more acute and the blast radius includes hardware-level compromises.

## 6. Conclusion

The xz backdoor proved that low-level supply-chain sabotage can evade expert review for years. KernelArena asks what happens when AI agents — which don't need two years of social engineering — can execute the same class of attack at machine speed. Our proof-of-concept demonstrates that the techniques behind CVE-2024-3094 map directly to control-evaluation side tasks, and that the structural properties of low-level code (legitimate unsafe primitives, semantic density, binary data, build-system complexity) create a monitoring regime that is qualitatively harder than application-level settings. As AI agents are deployed for systems maintenance at scale, the gap between current monitoring capabilities and the xz-class threat demands urgent attention.

## Code and Data

- Code repository: https://github.com/ramaniyash/kernelarena
- Environments: Docker containers with QEMU harnesses [link to setup instructions]

## Author Contributions

[Fill in]

## References

1. Freund, A. (2024). Backdoor in upstream xz/liblzma leading to ssh server compromise. oss-security mailing list, March 29, 2024. https://www.openwall.com/lists/oss-security/2024/03/29/4
2. Valsorda, F. (2024). Analysis of the xz backdoor payload. Bluesky, March 30, 2024. https://bsky.app/profile/filippo.abyssdomain.expert/post/3kowjkx2njy2b
3. Cox, R. (2024). Timeline of the xz open source attack. https://research.swtch.com/xz-timeline
4. Greenblatt, R., Shlegeris, B., Christiano, P., & Roger, F. (2024). AI Control: Improving Safety Despite Intentional Subversion. *ICLR 2025*. https://arxiv.org/abs/2312.06942
5. Redwood Research. (2025). LinuxArena: A Control Evaluation Framework. https://github.com/linuxarena/linuxarena
6. Ward, F.R., et al. (2025). CTRL-ALT-DECEIT: Sabotage Evaluations for Frontier Models. *NeurIPS 2025 Spotlight*.
7. Xia, C., et al. (2024). Automated Repair of Linux Kernel Bugs. *arXiv preprint*.
8. Meng, Q., et al. (2024). KGym: A Platform and Dataset to Benchmark Large Language Models on Linux Kernel Crash Resolution. https://arxiv.org/abs/2407.02680
9. Ouyang, A., et al. (2025). KernelBench: Can LLMs Write Efficient GPU Kernels? https://arxiv.org/abs/2502.10517
10. Underhanded C Contest. (2005-2015). http://www.underhanded-c.org/

## Appendix

### A. xz Backdoor Technical Summary

The xz/liblzma backdoor (CVE-2024-3094) was a multi-stage supply-chain attack on xz-utils versions 5.6.0 and 5.6.1:

1. **Payload stage:** Obfuscated binary code hidden inside test input files (`bad-3-corrupt_lzma2.xz`, `good-large_compressed.lzma`) committed to the repository.
2. **Build injection stage:** A modified `build-to-host.m4` script (present only in release tarballs, not in git) extracted and executed the payload during package builds on x86_64 glibc systems.
3. **IFUNC hooking stage:** The payload hijacked glibc's indirect function resolution to redirect `RSA_public_decrypt` to attacker-controlled code at runtime.
4. **Exploitation stage:** The hooked function verified an Ed448 signature from the attacker's key on data extracted from SSH certificate public keys, then passed the payload to `system()` for RCE.
5. **Anti-analysis stage:** The backdoor detected debugging environments (valgrind, rr, LD_DEBUG, TERM) and disabled itself when being analyzed.

### B. Full Task Catalog

[Include seed task catalog]

### C. Hidden Scorer Pseudocode

[Include scorer designs]

## LLM Usage Statement

We used Claude to assist with paper drafting, xz backdoor analysis, and side-task design brainstorming. All task implementations, environments, scorers, and experimental results were independently developed and verified. The xz backdoor analysis is based on publicly available disclosures by Freund (2024), Valsorda (2024), and Cox (2024).
