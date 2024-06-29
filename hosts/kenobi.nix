{ pkgs, ... }:

{
  pkgs = [
    pkgs.podman
    pkgs.podman-tui
    pkgs.skhd
    pkgs.yabai
    pkgs.tailscale
    # "brave" # not available on aarch64-apple-darwin
    # "steam" # not available on aarch64-apple-darwin
  ];

  casks = [
    "whatsapp"
    "brave-browser"
    "steam"
    "obsidian"
    "discord"
    "spotify"
    "whatsapp"
    # not available (nixpkgs nor brew)
    # "arkenforge"
    # "DungeonDraft"
  ];
}
