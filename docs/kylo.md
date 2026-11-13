# Kylo Raspberry Pi

Kylo is the Raspberry Pi camera node. The flake provides a generic ARM installer image separately from the Kylo configuration.

## Installer image

Build on an aarch64 machine, or enable aarch64 binfmt emulation when building from a non-ARM machine. The installer image is generic; it does not include Kylo's target-specific camera configuration.

Build the installer image:

```bash
nix build .#packages.aarch64-linux.rpi-installer
```

Write the resulting image to a disposable SD card using an operator-selected device:

```bash
zstdcat result/sd-image/*.img.zst | sudo dd of=<device> bs=4M conv=fsync status=progress
```

Use an appropriate image-writing command if the result is not compressed.

Boot the installer and confirm root bootstrap SSH access and local-console access before continuing. Host-specific setup is intentionally not documented here.

## First deployment

Bootstrap installer access is root-only. The image has a 512 MiB FAT boot firmware partition and an ext4 partition that is initially the installer root and later becomes Kylo's `/persist`. The generic installer leaves `/boot/firmware` unmounted. Before the first deployment, mount `<BOOT_PARTITION>` at `/boot/firmware` and verify it has at least 256 MiB free:

```bash
mount <BOOT_PARTITION> /boot/firmware
findmnt /boot/firmware
df -BM /boot/firmware
```

The first deployment must use `switch`, not `boot`, because activation installs the target-specific firmware and camera configuration:

```bash
nixos-rebuild switch --flake .#kylo \
  --target-host root@<TARGET> \
  --build-host root@<TARGET> \
  --use-substitutes
```

Before rebooting, confirm that `/boot/firmware` remains mounted, has at least 256 MiB free, and contains the rendered camera configuration, camera overlay, target firmware files, and bootloader. Verify `<USER>` SSH access and retain local-console access. Subsequent deployments use `<USER>`, not root.

The target requires host-specific setup and the repository's private flake input. Those steps are intentionally not documented here.

## Operational gotchas

- SD cards wear quickly under deployment churn. `EBADMSG` or CRC errors indicate a failing card.
- Kernels are stored under `/persist/boot`. The previous runbook stated a five-generation limit, but the public Kylo configuration does not declare that limit; verify the effective limit before relying on it.
- The camera configuration reserves 256 MiB of CMA memory. After rebooting, verify camera capture and available memory.
