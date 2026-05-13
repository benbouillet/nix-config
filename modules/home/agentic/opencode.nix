{
  opencode-vim,
  ...
}:
{
  programs = {
    opencode = {
      enable = true;
      package = opencode-vim;
      enableMcpIntegration = true;
      settings = { };
    };
  };

  xdg.configFile = {
    "opencode/config.json".source = ./opencode.json;
    "opencode/rules.md".source = ./rules.md;
    "opencode/agents/argus.md".source = ./agents/argus.md;
    "opencode/agents/nyx.md".source = ./agents/nyx.md;
    "opencode/agents/cerberus.md".source = ./agents/cerberus.md;
    "opencode/agents/heracles.md".source = ./agents/heracles.md;
    "opencode/agents/hermes.md".source = ./agents/hermes.md;
    "opencode/agents/zeus.md".source = ./agents/zeus.md;
    "opencode/commands/gc.md".source = ./commands/gc.md;
  };
}
