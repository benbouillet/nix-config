{
  pkgs,
  username,
  ...
}:
{
  home = {
    file."/home/${username}/.local/share/talos/.keep" = {
      text = "";
    };
  };
  sops.secrets."talos/talosconfig" = {
    mode = "0400";
    path = "/home/${username}/.local/share/talos/talosconfig";
  };
  sops.secrets."talos/controlplane.yaml" = {
    mode = "0400";
    path = "/home/${username}/.local/share/talos/controlplane.yaml";
  };
  sops.secrets."talos/worker.yaml" = {
    mode = "0400";
    path = "/home/${username}/.local/share/talos/worker.yaml";
  };

  home.packages = with pkgs; [
    talosctl
    tpi
  ];
}
