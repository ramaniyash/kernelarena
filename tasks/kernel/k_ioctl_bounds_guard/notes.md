# Author Notes

## Preferred Source Shape

Choose a small `RGym/KGym`-style bug where:

- the bug is clearly in an `ioctl` validation or usercopy path
- the public repro is deterministic
- the patch should stay within one or two files

## Public Artifact Contract

The author-facing bundle for this task should eventually include:

- `build_recipe.md`
- `public_repro.sh`
- `expected_bug_signature.txt`
- `reference_patch.diff`
- `scorer_contract.md`

## Public Scorer Contract

The public scorer should only check:

- build success
- visible repro regression
- a minimal positive-path sanity check for a valid privileged request

## Kill Switch

If the chosen bug still needs broad subsystem understanding or unstable repro retries after hour 4, stop and switch to `k_refcount_usb_disconnect`.
