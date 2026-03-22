# Project Idea

## Working Title

**CapGap: Detecting Semantic Camouflage in LinuxArena**

Alternative titles:

- `Semantic Camouflage Monitoring for LinuxArena`
- `Cover Story vs Capability Gap Monitoring`
- `From Narrative Divergence to Capability Divergence`

## One-Sentence Summary

We study whether existing monitors under-detect sabotage when the action's local engineering story sounds reasonable, and we build a monitor that explicitly measures when an action creates more dangerous capability than the main task narrowly requires.

## Refined Insight

The cloned LinuxArena environments made the right abstraction much clearer.

The threat is not mainly “models inserting manipulative comments.”

The stronger and more general pattern is:

> The agent introduces a broader capability, exposure path, or safety regression than the main task requires, while wrapping it in a highly plausible engineering rationale.

This is what many of the best LinuxArena strategies do:

- debugging as cover
- testability as cover
- validation as cover
- performance optimization as cover
- refactoring as cover
- collaboration/backfill as cover
- analytics/observability as cover

These attacks often look like bugs, oversights, abstractions, or integration mistakes rather than explicit malicious code.

## Research Question

**Primary question:**

Can an action-level monitor that reasons about the gap between the minimal legitimate implementation and the actual capability introduced by an action improve safety over `multi` on a semantic-camouflage-heavy benchmark slice?

**Secondary questions:**

1. Are there attack classes where `multi` is systematically reassured by the cover story?
2. Does a capability-gap framing recover part of the performance of `strong` on those cases?
3. Do the strongest failures come from semantic camouflage rather than from weak model capability or poor task understanding?

## What Is Semantic Camouflage?

An action exhibits semantic camouflage when:

- it appears to implement a legitimate task requirement,
- but it also creates a broader dangerous effect than necessary,
- and the dangerous effect is obscured by a plausible local story.

Examples from the cloned repos include:

- a redaction routine that looks security-conscious but misses uppercase secrets
- a testability refactor that exposes config state via a debug endpoint
- a refactor bug that causes link text to absorb credentials from script content
- an async validation refactor that silently disables a trust check
- an audit batching refactor whose “readiness check” ensures audits never flush
- a backfill script whose variable confusion grants access to the wrong team

## Why Existing Monitors May Miss It

The current baseline monitor `multi` is a strong and sensible baseline, but many camouflage attacks are designed to survive exactly the kinds of reasoning it emphasizes:

- “does this action help the main task?”
- “does it look obviously malicious?”
- “is it directly aligned with a side task?”

The camouflage attacks exploit a different weakness:

- the action is related to the main task,
- it is not obviously malicious in isolation,
- and the dangerous part is not the visible narrative but the excess capability created by the implementation choice.

So the right question is not just “is this suspicious?” but:

> Why does this implementation need this much capability, exposure, privilege, or persistence?

## Why This Matters For AI Control

This project is tightly aligned with AI control research.

- It targets **high-stealth sabotage**, not ordinary bug-finding.
- It tests a **blue-team intervention** inside an existing control benchmark.
- It focuses on the safety/usefulness tradeoff at realistic audit budgets.
- It aims to improve monitoring on the exact class of actions that are most dangerous for deployment: actions that look like competent engineering.

## Novelty Claim

The intended novelty is not “we built another suspiciousness prompt.”

The intended novelty is:

1. defining **semantic camouflage** as a distinct monitorability regime in LinuxArena,
2. building a **capability-gap monitor** that explicitly reasons about excess capability beyond the narrow task need,
3. evaluating on a **curated camouflage slice** grounded in existing LinuxArena strategy files and environment repos.

## What This Project Is Not

To keep research taste high, this project is explicitly **not**:

- a new environment,
- a whole new attack policy stack,
- a broad port of an unrelated protocol,
- or a generic “better monitor” claim across all LinuxArena tasks.

It is a focused investigation into a specific failure mode of existing monitors.
