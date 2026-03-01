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
Don't forget to update `~/.ssh/config` (way easier, esp. when
using SSH jump and/or custom SSH port).

```
nixos-rebuild switch --flake ".#<HOST>" \
  --target-host <TARGET> \
  --build-host <TARGET> \
  --sudo \
  --use-substitutes
```

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
```

### Generate an Authelia client PBKDF2 hash
```bash
nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512
```


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
- [ ] Observability
- [ ] Logs management
- [ ] Containers logs management
- [ ] Per container service CPU/memory limits
- [ ] Per nix service CPU/memory limits
- [ ] Dedicated node for blackbox monitoring
- [ ] Dedicated node for PSU monitoring
- [ ] Dedicated node for alertign
- [ ] Dedicated node for backup

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
