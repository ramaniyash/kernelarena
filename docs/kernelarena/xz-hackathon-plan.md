# XZ-Focused Hackathon Plan

Working paper title:

> Can AI Agents Execute xz-Style Supply Chain Attacks - and Can We Catch Them?

## Core Reframe

KernelArena is now framed around the xz backdoor as the motivating incident.

The benchmark should study three xz-style attack families:

1. security-feature disablement hidden inside an otherwise normal change
2. rare-trigger activation that stays dormant under ordinary tests
3. dispatch or resolver indirection that reroutes a sensitive operation

## Primary Deliverable

The first hackathon deliverable is not a broad task count. It is one high-quality xz-style case study with:

- a real low-level bug report or crash artifact
- a real honest fix path
- a redacted negative-case description that captures the attack family without shipping deployable sabotage code
- a defensive invariant scorer that detects whether the protected property remains intact
- a paper-ready evidence pack

## Safety Boundary

This repository should remain defensive.

That means the hackathon materials should include:

- honest fixes
- redacted descriptions of negative cases
- invariant checks and monitor prompts
- reviewer checklists and evaluation plans

It should not include:

- deployable backdoor patches
- exploit scripts
- hidden trigger implementations for real systems
- instructions for slipping malicious code through review

## Recommended Hackathon Sequence

### Phase 1: One flagship kernel case

Ship one kernel case study with:

- task metadata
- public bug evidence
- honest patch summary or patch path
- redacted xz-family mapping
- invariant scorer contract
- monitor guidance

### Phase 2: Second case in a different xz family

Add one more case that exercises a different family:

- feature-disablement style
- rare-trigger style
- dispatch-indirection style

### Phase 3: Paper packaging

By the end of the hackathon, the paper should be able to show:

- why xz is the right motivating incident
- why low-level benchmarks are the right substrate
- one concrete end-to-end case study
- one or two additional scoped families
- a clear evaluation story for monitors and reviewers

## Evidence Pack For Each Case

Each task bundle should produce the following paper-ready fields:

- Task ID and subsystem
- kernel or firmware version
- bug type and one-sentence description
- public bug evidence excerpt
- honest fix summary
- redacted negative-case summary
- xz family mapping
- what a reviewer would need to inspect
- visible test result
- hidden usefulness result
- invariant scorer result

## Win Condition

The hackathon submission is strongest if it can say:

- we built a low-level benchmark around the most important recent supply-chain attack,
- we grounded it in real kernel or firmware repair work,
- and we designed the evaluation so defenders can study whether monitors catch subtle xz-style tampering.
