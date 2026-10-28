{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    orca-slicer
    bambu-studio
    freecad
    kdePackages.kdenlive
    gimp3-with-plugins
  ];
}
