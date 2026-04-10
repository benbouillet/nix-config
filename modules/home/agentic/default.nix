{
  opencode-augment-auth,
  ...
}:
{
  programs = {
    opencode = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        plugin = [ "${opencode-augment-auth}" ];
      };
    };
  };

  xdg.configFile = {
    "opencode/config.json".source = ./opencode.json;
    "opencode/rules.md".source = ./rules.md;
    "opencode/agents/sre.md".source = ./agents/sre.md;
    "opencode/agents/nix.md".source = ./agents/nix.md;
    "opencode/commands/gc.md".source = ./commands/gc.md;
  };
}
