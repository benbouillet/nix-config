{ pkgs, ... }:

{
  pkgs = [
    pkgs.colima
    pkgs.docker
    (pkgs.google-cloud-sdk.withExtraComponents [pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    # pkgs.podman-tui
    pkgs.skhd
    pkgs.yabai
    # "brave" # not available on aarch64-apple-darwin
    # "steam" # not available on aarch64-apple-darwin
    pkgs.go-task
  ];

  casks = [
    "whatsapp"
    "brave-browser"
    "steam"
    "notion"
    "obsidian"
    "discord"
    "spotify"
    "whatsapp"
    "tailscale"
    # not available (nixpkgs nor brew)
    # "arkenforge"
    # "DungeonDraft"
  ];
}
