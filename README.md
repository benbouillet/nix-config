# Homelab Configurations

## How to

### Prepare a USB bootable nix system

```
nix build .#usbboot
sudo dd if=result/iso/<ISO_FILE> of=/dev/<USBKEY> bs=4M conv=fsync status=progress
```

### Provision a new machine

```
nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./hosts/chewie/hardware-configuration.nix \
  --flake .#chewie \
  --target-host root@<IP>
  --ssh-port <SSH_PORT>
```

# TO DO
- [x] Hyprland implementation
- [x] Hyprland configuration
- [x] Hyprland basics bindings
- [x] Hyprland advanced bindings
- [x] Kitty configuration
- [x] Wallpaper implementation
- [x] Stylix implementation
- [x] Stylix configuration (color scheme)
- [x] Stylix configuration (font)
- [x] Zsh implementation
- [x] Zsh configuration
- [x] Waybar implementation
- [x] Waybar configuration
- [x] Screen brightness management
- [x] nixvim implementation
- [x] `greetd` implementation
- [x] notifications
- [x] web-search
- [x] hyprland shortcuts cheatsheet
- [x] emopicker
- [x] thunar
- [x] T480 keyboard bindings
- [x] hypridle
- [x] hyprlock
- [x] hyprpaper
- [x] hyprshot
- [x] hyprsunset
- [x] xdg-desktop-portal-hyprland
- [x] nixvim configuration tweaking
- [x] Waybar modules
- [x] Waybar base ricing
- [x] Waybar modules colors
- [x] Waybar executables on click
  - [x] logout
  - [x] hyprlock
  - [x] pulseaudio
  - [x] bluetooth
  - [x] network manager
  - [x] calendar
- [x] Waybar hover behavior (WIP)
- [x] Waybar MPRIS (media player)
- [x] Waybar download/upload bandwith (see [this](https://www.reddit.com/r/unixporn/comments/1b1rmls/sway_catppuccin_mocha_ags_waybar/))
- [x] Waybar Mic Input volume
- [x] Waybar remove unused code
- [x] Waybar colors from Stylix
- [x] Switching to Hyprland with [`uwsm`](https://wiki.hyprland.org/Getting-Started/Master-Tutorial/#launching-hyprland)
- [x] spotify
- [x] tmux
- [ ] investigate Tesseract (see [example](https://github.com/AtaraxiaSjel/nixos-config/blob/61a428d955bb696d907935f65b764a8ab4acc8a2/profiles/workspace/wayland/hyprland.nix#L24C85-L24C94))
- [x] Waybar temperature module
- [x] Finish swaync integration from same
- [x] emoji-picker
- [x] sops-nix
- [x] syncthing
- [x] wireless
- [x] notification center
- [x] Solve the missing applications in launcher issue (see [HM Documentation](https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.desktopEntries))
- [x] fix firefox config file backup error to HM (check [issue](https://github.com/nix-community/home-manager/issues/4199#issuecomment-2226810699))
- [ ] Check on tmux shortcuts
- [x] secrets
- [x] check what can be switch to HM options in sre.nix & personal.nix
- [ ] configure external monitors
- [ ] caching
- [ ] formatting
- [ ] investigate LF (see [Vimjoyer's video](https://www.youtube.com/watch?v=z8y_qRUYEWU))
- [ ] notification center: solve UI issue with wlogout button
- [ ] hyprswitch ?
- [ ] swappy ?
- [ ] code snippet screenshot tool (check [medium](https://medium.com/sysf/taking-easy-screenshots-of-your-code-with-this-awesome-cli-tool-bcc43aec653a))
- [ ] ssh-agent

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
