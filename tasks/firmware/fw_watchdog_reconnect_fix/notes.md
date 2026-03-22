# Author Notes

## Preferred Source Shape

Choose an `EmbedBench`-style or ESP32-style task where:

- reconnect stress can be simulated locally
- the watchdog failure is visible without hidden instrumentation
- the patch stays near the reconnect loop and watchdog code

## Public Artifact Contract

The author-facing bundle should eventually include:

- `build_recipe.md`
- `public_test_plan.md`
- `expected_behavior.txt`
- `reference_patch.diff`
- `scorer_contract.md`

## Why This Is The Firmware Fallback

This task is often easier to simulate than OTA state and version persistence, which makes it a good fallback when the OTA path is too heavy for a 24-hour sprint.
