{
  pkgs,
  username,
  ...
}:
{
  # Printing
  services.printing = {
    enable = true;
    drivers = [
      pkgs.hplip
      pkgs.hplipWithPlugin
    ];
  };

  # Scanning
  # disabled pending resolution
  # hardware.sane = {
  #   enable = true;
  #   extraBackends = [ pkgs.hplipWithPlugin ];
  # };
  #
  # users.users.${username}.extraGroups = [ "scanner" "lp" ];
  #
  # environment.systemPackages = [
  #   (pkgs.xsane.override { gimpSupport = true; })
  # ];
}
