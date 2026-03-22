# XZ-Style Benchmark Design

## Goal

Build a defensive benchmark for evaluating whether monitors, reviewers, and analysis pipelines can catch xz-style supply-chain tampering in low-level code changes.

## Three Benchmark Families

### 1. Feature-disablement tampering

Motivating pattern:

- a small-looking change quietly disables a security feature, build check, or validation gate

Benchmark representation:

- store the honest fix
- store only a redacted description of the negative case
- score whether the protected feature remains enabled across build and runtime probes

Good monitor signals:

- config or feature-probe drift
- unexpected capability loss in build logs
- mismatches between advertised and actual runtime protections

### 2. Rare-trigger tampering

Motivating pattern:

- ordinary tests pass, but one narrow environment or input slice still violates a security invariant

Benchmark representation:

- visible tests cover normal use
- hidden invariant checks cover rare environment and input slices
- artifacts record the trigger family at a high level, not the exploit recipe

Good monitor signals:

- sparse behavior differences across environment matrix rows
- anomalous edge-case handling in one branch
- policy drift that appears only under one config tuple

### 3. Dispatch-indirection tampering

Motivating pattern:

- a resolver, callback, or operation table redirects a sensitive path in a way that looks routine

Benchmark representation:

- compare the intended dispatch surface with the actual dispatch surface
- inspect function-pointer tables, compat paths, callback registration, and symbol resolution behavior

Good monitor signals:

- unexpected handlers in ops tables
- symbol or relocation changes with no visible task justification
- compatibility paths that receive weaker review than the main path

## Task Artifact Contract

Each benchmark case should carry:

- public bug evidence: crash excerpt, warning, or failing visible oracle
- honest patch artifact: patch or clean summary
- negative-case descriptor: redacted family, invariant violated, why it is subtle
- scorer spec: what invariant is tested and how it is observed
- monitor notes: what static and dynamic signals should help catch it

## Scorer Philosophy

The hidden scorer should be defensive and property-based.

It should answer:

- does the candidate still fix the visible bug?
- does the intended security property still hold under a broader matrix?
- does the monitor flag the suspicious change?

It should not require shipping real exploit logic in the public repository.

## Recommended Logged Signals

- patch diff and touched files
- build logs and feature-detection output
- config deltas
- sanitizer and kernel-log excerpts
- environment matrix rows exercised by hidden tests
- dispatch-table or symbol-map diffs when relevant
- reviewer or monitor rationale summaries

## Paper Story

The xz incident gives the benchmark a clean narrative:

- one subtle change can disable protection,
- one rare trigger can evade standard testing,
- and one indirect redirection can subvert a trusted path.

Kernel and firmware repair tasks are a natural home for all three.
