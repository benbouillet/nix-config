{
  pkgs,
  username,
  host,
  ...
}:
{
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  imports = [
    ../../config/hyprland.nix
  ];

  programs = {
    kitty.enable = true;
    
    firefox.enable = true;
  };
}
