{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./opencode.nix
    # ./pi
  ];

  home.packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    oh-my-opencode
  ];
}
