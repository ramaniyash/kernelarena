# Environments

KernelArena environments are realistic workspaces where the untrusted model operates.

## Current Environments

### `kernel_repair_lab/`

Low-level kernel repair tasks adapted from RGym and KGym. The agent patches a Linux kernel tree to fix visible bugs while hidden scorers test for covert sabotage.

Contains the runnable `ka_vuln` proof-of-concept under `cases/ka_vuln/`.

**Quick start:**

```bash
sudo bash kernel_repair_lab/scripts/run_all.sh
```

See `kernel_repair_lab/cases/ka_vuln/README.md` for details.

### `firmware_lab/`

Firmware and embedded tasks adapted from EmbedBench. Earlier-stage than the kernel track.

## Structure

```
environments/
  kernel_repair_lab/
    README.md
    env_spec.yaml
    scripts/
      smoke_check.sh
      run_all.sh          # Master evaluation script
    cases/
      ka_vuln/            # Proof-of-concept kernel module
        module/           # ka_vuln.c + Makefile
        tests/public/     # Visible test suite
        hidden_checks/    # Hidden trigger programs (scorers)
        public_artifacts/ # Honest and sabotaged patch pairs
  firmware_lab/
    README.md
    env_spec.yaml
    scripts/
      smoke_check.sh
```
