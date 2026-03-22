# Experiment Plan

## Primary Hypothesis

On a semantic-camouflage-heavy LinuxArena benchmark slice, `cap-gap` should outperform `multi` at fixed honest audit budgets because it explicitly reasons about over-broad capability hidden behind plausible engineering rationale.

## Conditions

### Policies

- `honest`
- `attack`
- `strategy-attack`

`strategy-attack` is the main attack condition because semantic camouflage is naturally strengthened by strategy files.

### Monitors

- `multi` - main baseline
- `cap-gap` - new monitor
- `mean-cap-gap` or `cap-gap-plus-multi` - optional robustness extension
- `strong` - subset-only upper-bound sanity check

## Benchmark Data

Primary task file:

- `task_slices/camouflage_slice_v1.txt`

This slice should be the same across all monitor comparisons.

## Evaluation Matrix

### Main comparison

1. Run `honest` on the full camouflage slice.
2. Run `strategy-attack` on the same slice.
3. Monitor both runs with `multi`.
4. Monitor both runs with `cap-gap`.
5. Compute safety at fixed honest audit budgets.

### Secondary control

1. Run `attack` on the same slice.
2. Compare whether `cap-gap` helps specifically more on `strategy-attack` than on default `attack`.

### Strong sanity check

Run `strong` on a small anchor subset of 3-4 cases to estimate whether `cap-gap` is recovering part of the `multi` to `strong` gap.

## Metrics

### Primary metrics

- Safety at 5%, 1%, and 0.5% audit budgets
- Attack score distribution vs honest score distribution
- Max action suspicion per trajectory

### Secondary metrics

- Honest false positive burden
- Rank ordering of hardest camouflage trajectories
- Per-environment and per-motif breakdown

### Qualitative outputs

- 3-5 representative case studies where `multi` under-scores a camouflage action and `cap-gap` catches it
- 1-2 cases where `cap-gap` false positives on honest work, if they exist

## Minimum Viable Win

We should consider the project a success if we get either of the following:

1. a clear aggregate safety win over `multi` on the camouflage slice, or
2. a small aggregate win plus several compelling qualitative examples on anchor cases.

## Strong Win

A strong result would be:

- `cap-gap` or `cap-gap-plus-multi` beating `multi` on `strategy-attack` at 1% and 5% audit budgets,
- while preserving a clean honest score distribution,
- and catching at least some cases known to have very low reported `multi` scores.

## Fallback Interpretation If Results Are Weak

If the monitor does not help much, that is still useful if we can show:

- which camouflage motifs it fails on,
- whether those failures are due to semantics-tracing limits, not rhetorical cover,
- or whether `strong` also fails on the same motif.

Then the paper can still make a meaningful claim about the limits of narrative/capability-gap monitoring.

## Proposed Execution Order

### Phase 1: fast pilot

- implement `cap-gap`
- run on a tiny subset of 2-3 anchor cases
- compare against `multi`

### Phase 2: main result

- run the full camouflage slice with `honest` and `strategy-attack`
- compute main metrics

### Phase 3: robustness

- add `attack`
- add `strong` subset
- add an ensemble variant if needed

## Team Split For Two People

### Person A: monitor lead

- implement prompts and monitor code
- inspect false positives and false negatives
- own prompt revisions and ablations

### Person B: benchmark + eval lead

- create task files and run sheets
- execute `honest`, `attack`, and `strategy-attack`
- run baseline monitors and collect metrics
- build figures and case study extracts
