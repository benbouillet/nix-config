# Homelab Configurations

## How to

### Prepare a USB bootable nix system

```
nix build .#usbboot
sudo dd if=result/iso/<ISO_FILE> of=/dev/<USBKEY> bs=4M conv=fsync status=progress
```

### Provision a new machine
Don't forget to update `~/.ssh/config` (way easier, esp. when
using SSH jump and/or custom SSH port).

```shell
nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./<HOST>/chewie/hardware-configuration.nix \
  --flake .#<HOST> \
  --target-host <TARGET>
```

Update the age key (depending on server or desktop, the path might change).
Register the machine into tailscale.
Update DNS is necessary.

### Deploy a new configuration

#### Remote host
Don't forget to update `~/.ssh/config` (way easier, esp. when
using SSH jump and/or custom SSH port).

```
nixos-rebuild switch --flake ".#<HOST>" \
  --target-host <TARGET> \
  --build-host <TARGET> \
  --sudo \
  --use-substitutes
```

#### Local host
```bash
sudo nixos-rebuild build --flake .#<hostname>
# nvd diff <current> <next>
nvd diff /nix/var/nix/profiles/system-511-link /nix/store/j10jc3ny8jmlzaq979yr0im2801y1781-nixos-system-obiwan-26.05.20260422.0726a0e
sudo nixos-rebuild switch --flake .#<hostname>
```

### Deploy Raspberry Pi (kylo)
1. Ensure aarch64 binfmt emulation is enabled on the build machine (`obiwan` has `boot.binfmt.emulatedSystems`).
2. Build the generic bootstrap installer image. It is not a pre-rendered Kylo image and does not contain Kylo's IMX219 firmware configuration:
   ```bash
   nix build .#packages.aarch64-linux.rpi-installer
   ```
3. Flash the image to the disposable SD card:
   ```bash
   zstdcat result/sd-image/*.img.zst | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
   ```
   Use plain `dd if=` if the output is an uncompressed `.img`.
4. Boot the installer and determine its current LAN address and confirm bootstrap SSH access. A human operator must complete the Kylo identity and SOPS bootstrap procedure from Obiwan before deploying the target, following the repository's secret-handling rules. This guide omits those secret-handling commands.
5. The image has two partitions: a 512 MiB FAT32 `/boot/firmware` partition (UUID `2178-694E`) followed by ext4 (UUID `44444444-4444-4444-8888-888888888888`), initially used as installer root and later mounted as Kylo `/persist`. The generic installer leaves `/boot/firmware` unmounted. Mount it and verify that it has at least 256 MiB free before the first Kylo deployment:
   ```bash
   mount /dev/disk/by-uuid/2178-694E /boot/firmware
   findmnt /boot/firmware
   df -BM /boot/firmware
   ```
6. Perform the first Kylo deployment as root with `switch`, not `boot`. Firmware files and the rendered IMX219 `config.txt` are installed by the system activation script, which `boot` does not run:
   ```bash
   nixos-rebuild switch --flake .#kylo \
     --target-host root@<pi-ip> \
     --build-host root@<pi-ip> \
     --use-substitutes
   ```
   Before rebooting, confirm `/boot/firmware` remains mounted, has at least 256 MiB free, and contains the rendered IMX219 `config.txt`, `overlays/imx219.dtbo`, Pi 4 firmware files, and `u-boot.bin`. Verify `ben` SSH access and retain local-console access before the reboot.
7. Subsequent deploys target `ben@` (root SSH is disabled by the config):
   ```bash
   nixdeploy kylo
   ```

Gotchas:
* SD cards wear out fast under NixOS deploy churn; `EBADMSG`/CRC errors indicate a dying card.
* Kylo uses a 512 MiB FAT boot partition at `/boot/firmware`, kernels on ext4 `/persist/boot`, and a generation limit of 5.

### Make a change in the disk configuration
When adding/removing a ZFS datasets, make the changes imperatively,
then document the change in [datasets.md](./hosts/chewie/disko/datasets.md).

Potential locations where nix configuration must mirror imperative commands:
* [zfs.nix](./hosts/chewie/zfs.nix) to add/remove the pools to mount at boot & update `sanoid` config
* [zpools.nix](./hosts/chewie/disko/zpools.nix) to add/remove zpools

### Create a new SOPS age key
```bash
age-keygen -o agekey.txt
# Get the public key
age-keygen -y agekey.txt
# Update .sops.yaml with the new public key
# Update secrets encryption
sops updatekeys secrets/secrets.yaml
```

### Generate an Authelia client PBKDF2 hash
```bash
nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512
```


# TODO

# Features
- [x] Tailscale-backed network layout
- [x] Server hardening
- [x] OCI containers deployment
- [x] nix modules deployment
- [x] ZFS datasets with at rest encryption
- [x] KVM compatible workflow for reboot
- [x] Impermanence
- [x] Reverse proxy
- [x] OIDC + SSO
- [x] Alerting
- [x] Monitoring
- [x] Logs management
- [x] Containers logs management
- [x] Per container service CPU/memory limits
- [ ] Dedicated node for PSU monitoring
- [x] Dedicated node for backup
- [x] VTT app
- [ ] Discord alternative
- [ ] ebooks management app
- [x] File-based Authelia authentication workflow
- [ ] Switch from linkding to linkwarden
- [ ] endurain
- [ ] technicium with split-horizon DNS
- [x] Split secrets per host
- [x] move observability to leia
- [x] implement backup to rsync
- [ ] implement DMZ pattern and network isolation for public-facing services (see docs/public-services-isolation.md)
- [x] re-check all basics monitoring on all hosts (zfs, cpu/memory, etc..)
- [x] simplify (back to yaml) observability stack and comment
- [x] ZFS backups monitoring & logs
- [ ] ZFS grafana dashboard
- [ ] Switch to Actions based renovate
- [ ] Logs on OOM from Loki
- [ ] Logs on rsync.net backups from Loki
- [ ] Logs on backups to yoda from Loki
- [ ] dendritic pattern
- [ ] Better Renovate config to catch specific sha & exotic versioning
- [ ] Decommission Tresorit
- [ ] Decommission Google Photos
- [ ] scan library
- [ ] Litellm

# Configuring SOPS

## Setting up SSH Key

```bash
ssh-keygen -t ed25519
```

## Deriving Age key from SSH

```bash
mkdir -p ~/.config/sops/age
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"
```

## Get Age public key

```bash
nix-shell -p age --run "age-keygen -y ~/.config/sops/age/keys.txt"
```

Then add the key to `.sops.yaml`

## Add keys to secret file

```bash
sops updatekeys secrets/secrets.yaml
```


## Updating SOPS secrets

```bash
sops secrets/secrets.yaml
```

# ZFS datasets

See [datasets.md](./hosts/chewie/disko/datasets.md)

## Hierarchy
```
chewie
├── ssd
│   ├── services
│   │   ├── infra
│   │   └── apps
│   ├── databases
│   │   ├── mysql
│   │   └── postgres
│   └── data
│       └── vaultwarden
└── hdd
    └── data
        ├── media
        ├── paperless
        ├── seafile
        └── immich
```

# Temporary Workarounds

This section lists temporary fixes applied to the configuration due to bugs introduced by `nixpkgs` or `flake` updates. These should be reviewed periodically and removed once the upstream issues are resolved.

## bambu-studio pinned to v02.06.01.55 (`modules/nixos/overlays.nix`)

nixpkgs is stuck on v02.05.00.67. The overlay replaces the source-built package with the official Ubuntu 24.04 AppImage to avoid compilation issues with new 2.6 dependencies. Remove once nixpkgs catches up.

## hmts.nvim disabled (`modules/home/neovim/plugins/treesitter.nix`)

`hmts.nvim` v1.3.0 (current nixpkgs version) crashes with `attempt to call method 'parent' (a nil value)` on any `.nix` file due to a nil capture not being guarded before calling `:parent()`. A fix is pending in [calops/hmts.nvim#38](https://github.com/calops/hmts.nvim/pull/38). Re-enable once the PR is merged and nixpkgs is updated.
