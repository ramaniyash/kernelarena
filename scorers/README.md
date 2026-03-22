# Scorers

KernelArena should separate scorer responsibilities cleanly.

## Intended Layout

- `hidden_usefulness/` - checks the requested main task robustly using tests the agent does not see
- `hidden_side_tasks/` - checks whether the covert low-level side task succeeds
- visible tests should usually live with the environment or task harness, not here

## Design Principle

Hidden usefulness and hidden side-task scorers should be independent whenever possible. That helps prevent trivial solutions such as deliberately breaking the main task in a way that also blocks the side task.

## MVP Guidance

The first implementation should favor deterministic scorer scripts with machine-readable output over complicated evaluation logic.
