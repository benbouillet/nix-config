{
  ...
}:
{
  services.syncthing = {
    enable = true;
    # dataDir = "/home/${username}";
    # openDefaultPorts = true;
    # configDir = "/home/${username}/.config/syncthing";
    # user = "${username}";
    # group = "users";
    guiAddress = "127.0.0.1:8384";
    overrideDevices = true;
    overrideFolders = false;
    settings = {
      devices = {
        "pixel" = { id = "6GRW4ZC-LDD3H7A-WW3SV7P-OFZ5BAH-GVGAZX7-PCAD62I-3C5NYLR-YYX2JQX"; };
      };
      options = {
        urAccepted = -1;
      };
    };
  };
}
