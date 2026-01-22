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

### Decrypt ZFS drives after reboot

On the target host:
```

```

# TO DO
- [ ] Check on tmux shortcuts
- [ ] investigate LF (see [Vimjoyer's video](https://www.youtube.com/watch?v=z8y_qRUYEWU))
- [x] `swappy`
- [x] code snippet screenshot tool (check [medium](https://medium.com/sysf/taking-easy-screenshots-of-your-code-with-this-awesome-cli-tool-bcc43aec653a))
- [ ] server: logs
- [ ] server: observability
- [ ] server: uptime monitoring
- [ ] server: alerting
- [ ] server: OIDC
- [ ] `zed` for server
- [ ] Server: foundryvtt
- [ ] Server: lubelogger
- [ ] Server: perplexica
- [x] Server: searxng
- [ ] Server: steam
- [x] Server: ollama
- [x] Server: open-webui
- [ ] Server: [recyclarr](https://recyclarr.dev/guide/getting-started/)
- [ ] Server: [mealie](https://mealie.io/)
- [ ] Server: Impermanence
- [x] Server: SSO with Authelia
- [ ] Server: OIDC with Authelia
- [ ] Server: SMTP with Authelia

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
