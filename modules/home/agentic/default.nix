{
  pkgs,
  ...
}:
{
  imports = [
    ./opencode.nix
  ];

  home.packages = with pkgs; [
    rtk
  ];
  home.sessionVariables = {
    "RTK_TELEMETRY_DISABLED" = "0";
  };
}
