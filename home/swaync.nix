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
              label = "󰐥";
              command = "${lib.getExe pkgs.wlogout}";
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
