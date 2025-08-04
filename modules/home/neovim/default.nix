{
  inputs,
  ...
}:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./options.nix
    ./keymappings.nix
    ./completion.nix
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    enableMan = true;

    nixpkgs.useGlobalPackages = true;

    viAlias = true;
    vimAlias = true;
  };
}
