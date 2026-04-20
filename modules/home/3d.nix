{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    orca-slicer
    bambu-studio
    freecad
  ];
}
