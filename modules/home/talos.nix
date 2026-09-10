{
  pkgs,
  username,
  ...
}:
{
  sops.secrets."talos/talosconfig" = {
    owner = username;
    group = username;
    mode = "0400";
    path = "/home/${username}/.local/share/talos/";
  };
  sops.secrets."talos/controlplane.yaml" = {
    owner = username;
    group = username;
    mode = "0400";
    path = "/home/${username}/.local/share/talos/";
  };
  sops.secrets."talos/worker.yaml" = {
    owner = username;
    group = username;
    mode = "0400";
    path = "/home/${username}/.local/share/talos/";
  };

  home.packages = with pkgs; [
    talosctl
    tpi
  ];
}
