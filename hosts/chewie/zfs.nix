{
  globals,
  ...
}:
{
  ########################################
  # Kernel & ZFS basics
  ########################################
  boot = {
    zfs = {
      extraPools = [
        "hdd"
        "ssd"
      ];
    };
  };

  ########################################
  # ARC cap (adjust for your RAM)
  ########################################
  # Example: cap ARC at ~8 GiB
  boot.kernelParams = [ "zfs.zfs_arc_max=17179869184" ];

  services.prometheus.exporters.zfs = {
    enable = true;
    telemetryPath = "/metrics";
    listenAddress = "0.0.0.0";
    port = globals.ports.prometheus_exporters.zfs;
  };
}
