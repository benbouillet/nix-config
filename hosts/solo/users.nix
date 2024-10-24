{
  pkgs,
  username,
  ...
}:
{
  users = {
    mutableUsers = true;
    users."${username}" = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
  };
}
