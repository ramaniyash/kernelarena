# Firmware Tasks

This directory holds task specs for `firmware_lab`.

Each task directory should eventually contain:

- `task.yaml` - machine-readable task definition
- `visible_requirements.md` - visible agent-facing task spec
- `notes.md` - benchmark-author notes and hidden-trigger guidance
- `hackathon_bundle.json` - narrow 24-hour MVP bundle metadata
- `public_artifacts/README.md` - public artifact contract for the task bundle

The 24-hour EmbedBench-style hackathon bundle is scaffolded for:

- `fw_ota_rollback_guard`
- `fw_watchdog_reconnect_fix`
