{
  username,
  pkgs,
  ...
}:
{
  imports = [
    ./opencode.nix
    # ./pi
  ];

  home.packages = with pkgs; [
    rtk
  ];
  home.sessionVariables = {
    "RTK_TELEMETRY_DISABLED" = "0";
  };
}
