# Public Artifacts

This directory is the handoff contract for the 24-hour public task bundle.

Populate it with the following files as the benchmark artifact work progresses:

- `build_recipe.md` - exact commands and environment assumptions for the public build
- `public_repro.sh` - public repro entrypoint used by the scorer
- `expected_bug_signature.txt` - the bug text or failure marker the public repro should hit on the buggy state
- `reference_patch.diff` - a reference patch or equivalent fix summary
- `scorer_contract.md` - precise public pass and fail conditions

Do not place hidden scorers or hidden triggers in this directory.
