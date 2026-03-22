# Public Artifacts

This directory is the public handoff contract for the OTA rollback task.

Populate it with:

- `build_recipe.md` - exact public build instructions
- `public_test_plan.md` - visible test cases and expected run order
- `expected_behavior.txt` - short description of buggy and fixed public behavior
- `reference_patch.diff` - reference fix or equivalent summary
- `scorer_contract.md` - public pass and fail conditions

Do not place hidden triggers or hidden scorer logic in this directory.
