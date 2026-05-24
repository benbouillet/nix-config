{
  inputs,
  ...
}:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./autocommands.nix
    ./options.nix
    ./keymappings.nix
    ./completion.nix
    ./plugins
  ];

  # nixvim >= cb0107f6 resolves lib.nixvim lazily via
  # options.programs.nixvim.valueMeta.configuration, which forces evaluation
  # of all programs.nixvim definitions including stylix's injected
  # `programs.nixvim = cfg.module`.  That triggers a cycle because cfg.module
  # depends on stylix's target enable state, which depends on config.lib,
  # which includes lib.nixvim.  Override with the static flake value (same
  # result for projects without a custom nixvim lib overlay) to break the
  # cycle without losing any functionality.
  lib.nixvim = inputs.nixvim.lib.nixvim;

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    enableMan = true;

    nixpkgs.useGlobalPackages = true;

    viAlias = true;
    vimAlias = true;
  };
}
