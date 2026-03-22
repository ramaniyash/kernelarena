# Local LinuxArena Setup

This machine now has a local low-level benchmarking workspace at `linuxarena/`.

## Workspace Layout

- `linuxarena/benchmarks/kgym/` - `Alex-Mathai-98/kGym-Kernel-Gym`
- `linuxarena/benchmarks/kgymsuite/` - `ARiSE-Lab/kGymSuite`
- `linuxarena/benchmarks/embedbench/` - `mitcriticaldatacolombia/EmbedBench` clone; the upstream repo is currently empty
- `linuxarena/benchmarks/embedagent/` - `icip-cas/EmbedAgent`, which includes `dataset/EmbedBench.json`
- `linuxarena/benchmarks/kernelbench/` - `ScalingIntelligence/KernelBench`
- `linuxarena/kernel_repair_lab/linux/` - local Linux kernel source snapshot (`v6.8`)

## Kernel Artifacts

- Kernel source root: `linuxarena/kernel_repair_lab/linux/`
- Kernel build metadata: `linuxarena/kernel_repair_lab/linux/Kbuild`
- Generated kernel config: `linuxarena/kernel_repair_lab/linux/.config`
- Key enabled options in `.config`:
  - `CONFIG_KASAN=y`
  - `CONFIG_KASAN_GENERIC=y`
  - `CONFIG_KASAN_INLINE=y`
  - `CONFIG_KASAN_VMALLOC=y`
  - `CONFIG_KCOV=y`
  - `CONFIG_FRAME_POINTER=y`
  - `CONFIG_UNWINDER_FRAME_POINTER=y`
  - `CONFIG_CMDLINE="console=ttyS0 nokaslr"`
  - `CONFIG_SERIAL_8250_CONSOLE=y`
  - `CONFIG_VIRTIO_NET=y`
  - `CONFIG_9P_FS=y`

## Docker And QEMU

- Docker is already installed and the daemon is active.
- Docker Compose is available through `sudo docker compose`.
- QEMU packages were installed locally, including `qemu-system-x86`, `qemu-system-arm`, `qemu-system-misc`, `qemu-utils`, and EFI images.
- `kvm-ok` succeeds on this machine, so KVM acceleration is available.

## kGymSuite Local Prep

- Local compose config was adjusted for a single-machine setup:
  - `linuxarena/benchmarks/kgymsuite/deployment/local/config.json`
  - `linuxarena/benchmarks/kgymsuite/deployment/local/kgym-runner.env`
- Base userspace images were downloaded to:
  - `linuxarena/benchmarks/kgymsuite/deployment/local/bucket/userspace-images/buildroot.raw`
  - `linuxarena/benchmarks/kgymsuite/deployment/local/bucket/userspace-images/bullseye.raw`

To build and start the local stack:

```bash
cd linuxarena/benchmarks/kgymsuite
sudo env DEPLOYMENT=local docker compose -f ./deployment/local/compose.yml --project-directory . build
sudo env DEPLOYMENT=local docker compose -f ./deployment/local/compose.yml up -d kmq kscheduler kdashboard kbuilder kvmmanager kprebuilder
```

## Note On RGym

`RGym` was not cloned because no public repository URL could be identified from the current GitHub and arXiv metadata at setup time. Once a public repo is available, it should be added under `linuxarena/benchmarks/rgym/`.
