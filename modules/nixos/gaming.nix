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

  environment.systemPackages = with pkgs; [
    pkgs.gamescope
    pkgs.steamtinkerlaunch
  ];

  environment.sessionVariables = {
    # Enable ACO shader compiler for RADV (faster shader compilation)
    RADV_PERFTEST = "aco";
    # Enable DRI3 for better performance
    LIBGL_DRI3_DISABLE = "0";
    # Prefer AMDVLK over RADV (uncomment if you want to try proprietary)
    # AMD_VULKAN_ICD = "RADV";
  };
}
