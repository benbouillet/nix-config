{
  casks = [
    "whatsapp"
    "brave-browser"
    "steam"
    # not available (nixpkgs nor brew)
    # "arkenforge"
    # "DungeonDraft"
  ];
  pkgs = [
    # "brave" # not available on aarch64-apple-darwin
    "tailscale"
    "docker"
    "obsidian"
    "slack"
    "discord"
    "spotify"
    # "steam" # not available on aarch64-apple-darwin
  ];
}
