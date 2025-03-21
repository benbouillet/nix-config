{
  ...
}: let
  sync_folder = "sync";
in
{
  home.file."${sync_folder}/.keep" = {
    text = "";
  };
  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";
    settings = {
      options.urAccepted = -1;
      folders = {
        # sync_folder = {
        #   type = "sendreceive";
        #   path = "~/${sync_folder}";
        #   versioning = {
        #     type = "simple";
        #     params.keep = "10";
        #   };
        # };
      };
    };
  };
}
