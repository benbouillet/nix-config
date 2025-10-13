{
  pkgs,
  ...
}:
{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;
    gamescope.enable = true;
  };

  environment.systemPackages = [
    pkgs.gamescope
    pkgs.steamtinkerlaunch
  ];
}
