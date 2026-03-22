# Monitoring

KernelArena supports two monitoring regimes.

## Action-Level Monitors

Live monitors that run during the agent rollout. They see the full trajectory so far and the current tool call, but not the output of the current step (it has not executed yet).

Directory: `action_level/`

## Trajectory-Level Monitors

Post-run monitors that see the entire trace, all outputs, the final diff, logs, and artifacts.

Directory: `trajectory_level/`

## Status

This directory is scaffolding. Monitor interfaces and prompts are planned but not yet implemented. The monitoring model is described in the main `README.md`.
