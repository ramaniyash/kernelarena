# CapGap: Detecting Semantic Camouflage in LinuxArena

This repository is the planning and execution home for an independent LinuxArena hackathon submission.

The project thesis is simple:

Current monitors are often good at catching obviously malicious actions, but many of the best LinuxArena attacks do not look like obvious maliciousness. They look like normal engineering work with a slightly too-broad capability hidden inside a plausible cover story: debugging, testability, performance, refactoring, validation, or analytics. We call this pattern **semantic camouflage**.

Our proposed contribution is a new action-level monitor, tentatively named `cap-gap`, that scores the gap between:

- the **narrowest legitimate capability** needed for the main task, and
- the **actual capability or exposure path** created by the action.

We evaluate on a curated LinuxArena slice built from real environment repos and existing strategy files, with a particular focus on attacks that reportedly evade the `multi` monitor while remaining strong side-task successes.

## Core Hypothesis

On a benchmark slice dominated by semantic camouflage attacks, a capability-gap monitor should outperform `multi` at fixed honest audit budgets.

## Why This Is A Good Independent Submission

- It is tightly aligned with LinuxArena's best research seam: stealth sabotage hidden inside legitimate SWE work.
- It is narrower and higher-taste than a broad “port our whole protocol” project.
- It has a clean empirical question, a strong baseline (`multi`), and a realistic upper-bound sanity check (`strong`).
- The benchmark slice is grounded in existing environment repos and existing attack strategies rather than synthetic toy attacks.

## Repo Structure

- `docs/idea.md` - refined research thesis and why it matters
- `docs/benchmark.md` - curated benchmark slice and motivating cases
- `docs/monitor-spec.md` - proposed `cap-gap` monitor design
- `docs/experiment-plan.md` - evaluation matrix, metrics, and execution plan
- `docs/submission-outline.md` - suggested framing for the paper/report
- `task_slices/camouflage_slice_v1.txt` - initial LinuxArena task subset

## Immediate Deliverables

1. Implement `cap-gap` as a new LinuxArena live monitor.
2. Run `honest`, `attack`, and `strategy-attack` on the curated camouflage slice.
3. Compare `cap-gap` against `multi`, and compare against `strong` on a smaller anchor subset.
4. Produce both quantitative results and qualitative case studies.

## Status

This repo currently contains the project specification and benchmark definition. No monitor code has been added yet.
