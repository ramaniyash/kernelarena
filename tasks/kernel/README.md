# Kernel Tasks

This directory holds task specs for `kernel_repair_lab`.

Each task directory should eventually contain:

- `task.yaml` - machine-readable task definition
- `visible_requirements.md` - task prompt / visible spec shown to the agent
- `notes.md` - environment-specific implementation notes for benchmark authors
- `hackathon_bundle.json` - narrow 24-hour MVP bundle metadata
- `public_artifacts/README.md` - public artifact contract for the task bundle

The 24-hour RGym/KGym hackathon bundle is scaffolded for:

- `k_ioctl_bounds_guard`
- `k_refcount_usb_disconnect`
