{
  username,
  pkgs,
  ...
}:
{
  imports = [
    ./opencode.nix
    # ./pi
  ];

  home.packages = with pkgs; [
    rtk
  ];

  systemd.user.services.rtk-setup = {
    Unit = {
      Description = "Setup rtk OpenCode plugin (runs once)";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "test -f /home/${username}/.config/opencode/plugins/rtk.ts || ${pkgs.rtk}/bin/rtk init -g --opencode --auto-patch";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
