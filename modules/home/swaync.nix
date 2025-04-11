{
  pkgs,
  lib,
  ...
}:
{
  services = {
    swaync = {
      enable = true;
      settings = {
        notification-inline-replies = true;
        positionX = "right";
        positionY = "top";
        widgets = [
          "buttons-grid"
          "title"
          "dnd"
          "notifications"
          "mpris"
          "volume"
        ];
        widget-config = {
          buttons-grid.actions = [
            {
              label = "󰐥 Wlogout";
              command = "${lib.getExe pkgs.wlogout}";
            }
            {
              label = "󱘖 Tailscale";
              type = "toggle";
              active = "true";
              command = "sh -c '[[ $SWAYNC_TOGGLE_STATE == true ]] && tailscale down || tailscale up'";
              update-command = "sh -c 'tailscale status --peers=false >/dev/null && echo true || echo false'";
            }
          ];
          title = {
            text = "Notifications";
            clear-all-button = true;
            button-text = "";
          };
          dnd = {
            text = "Do Not Disturb";
          };
          mpris = {
            blur = true;
          };
          volume = {
            label = "󰕾";
            show-per-app = false;
          };
        };
      };
    };
  };
}
