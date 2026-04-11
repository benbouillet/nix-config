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
      extraPools = [ "ssd" ];
    };
  };

  ########################################
  # ARC cap (adjust for your RAM)
  ########################################
  # Cap ARC at ~16 GiB
  boot.kernelParams = [ "zfs.zfs_arc_max=17179869184" ];

  services.prometheus.exporters.zfs = {
    enable = true;
    telemetryPath = "/metrics";
    listenAddress = "0.0.0.0";
    port = globals.ports.prometheus_exporters.zfs;
  };
}
