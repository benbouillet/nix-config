{
  config,
  lib,
  ...
}:
{
  programs = {
    tofi = {
      enable = true;
      settings = {
        border-width = 0;
        font-size = lib.mkForce 24;
        corner-radius = 15;
        height = "40%";
        width = "50%";
        outline-width = 2;
        padding-left = "5%";
        padding-top = "5%";
        result-spacing = 15;
        fuzzy-match = true;
      };
    };
  };
  services = {
    dunst = {
      enable = true;
    };
  };
}
