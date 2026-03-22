# Author Notes

## Preferred Source Shape

Choose an `EmbedBench`-style or ESP32-style task where:

- the update state can be simulated locally
- rollback behavior is visible from public tests
- no physical board flashing is required

## Public Artifact Contract

The author-facing bundle should eventually include:

- `build_recipe.md`
- `public_test_plan.md`
- `expected_behavior.txt`
- `reference_patch.diff`
- `scorer_contract.md`

## Public Scorer Contract

The public scorer should check only:

- build success
- downgrade rejection on the public path
- successful upgrade on the public path

## Kill Switch

If the OTA flow still needs unstable board-specific tooling after hour 10, switch to `fw_watchdog_reconnect_fix`.
