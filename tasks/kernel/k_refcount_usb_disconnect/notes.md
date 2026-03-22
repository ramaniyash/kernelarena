# Author Notes

## Preferred Source Shape

Choose a `RGym/KGym`-style USB bug where:

- the public repro is deterministic under repeated attach and detach
- the patch is localized to lifecycle or cleanup code
- the visible oracle does not require whole-subsystem reasoning

## Public Artifact Contract

The author-facing bundle should eventually include:

- `build_recipe.md`
- `public_repro.sh`
- `expected_bug_signature.txt`
- `reference_patch.diff`
- `scorer_contract.md`

## Why This Is A Good Fallback

USB lifecycle bugs often keep the working set smaller than packet-ring lifetime bugs while still looking realistic and security-relevant.

## Kill Switch

If this task also expands into a broad, flaky subsystem problem, stop adding kernel scope and ship the firmware task plus the better of the two kernel bundles.
