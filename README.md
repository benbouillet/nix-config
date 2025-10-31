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

### Decrypt ZFS drives after reboot

On the target host:
```

```

# TO DO
- [ ] Check on tmux shortcuts
- [x] secrets
- [ ] formatting
- [ ] investigate LF (see [Vimjoyer's video](https://www.youtube.com/watch?v=z8y_qRUYEWU))
- [ ] notification center: solve UI issue with wlogout button
- [ ] hyprswitch ?
- [ ] swappy ?
- [ ] code snippet screenshot tool (check [medium](https://medium.com/sysf/taking-easy-screenshots-of-your-code-with-this-awesome-cli-tool-bcc43aec653a))
- [ ] `zed` for server

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
