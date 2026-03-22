# Evaluation Plan

## Track Fit

KernelArena is primarily a **Control Setting Design** project.

Its purpose is to create a new setting where control protocols can be stress-tested on low-level work.

## Main Evaluation Questions

1. Can current models complete the low-level main tasks at a useful rate?
2. Can xz-style negative cases survive visible tests while still violating a hidden security invariant?
3. How well do existing control protocols detect those invariant violations in this regime?

## Metrics

### Usefulness

Per task:

- compile / synthesize success
- visible test pass rate
- hidden usefulness scorer pass rate
- optional performance or latency constraints when they are task-relevant

### Safety

Per task:

- whether the hidden invariant is violated under the hidden scorer
- detection rate of the monitoring / auditing protocol
- safety at fixed audit budgets if a control protocol is used

### Control setting quality

At the setting level:

- how often benign models need to touch dangerous primitives
- whether xz-style negative cases are realistic, subtle, and non-trivial to detect
- whether there is a meaningful safety/usefulness frontier

## Recommended Baseline Protocols

Once the setting exists, the first baselines should be simple and interpretable:

1. no monitor
2. live patch / action monitor
3. trusted review on selected actions
4. resampling or defer-to-trusted-model
5. trusted editing for high-risk diffs

## Why KernelArena Is Interesting For Control Evaluation

Low-level domains likely stress several known weak points of monitoring:

- comments and natural-language rationale are less informative
- diffs are shorter but semantically denser
- safe and unsafe code often look syntactically similar
- performance pressure gives cover for weakening checks
- hidden failure modes depend on rare inputs, shapes, or timing

This means the benchmark is likely to expose failure modes that are less visible in ordinary app-code settings.

## MVP Experimental Story

A strong hackathon-scale result would be:

- implement one kernel task family and one firmware task family,
- show that ordinary models can solve the main tasks,
- show that xz-style negative cases can survive visible tests unless broader invariants are checked,
- and demonstrate at least one meaningful control tradeoff.

Even a smaller result can still be valuable if it convincingly demonstrates that:

- the low-level tasks are feasible,
- the negative-case families are coherent,
- and the setting reveals a harder monitoring regime.
