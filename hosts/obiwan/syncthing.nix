{
  username,
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
        "pixel" = { id = "DAPOL32-UCPTKEC-UKN2ZI7-LFXCIT7-BACEC6R-R3KP7DC-JN7UEXS-ZXS6SA6"; };
        "windu" = { id = "7WUXUQS-BPY7X37-5OMTXRQ-XOOBJE2-BQ4AYNV-RRCJPUI-K6X6X56-4XPOWQ4"; };
      };
      options = {
        urAccepted = -1;
      };
    };
  };
}
