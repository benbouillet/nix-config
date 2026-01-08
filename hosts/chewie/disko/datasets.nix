{
  username,
  ...
}:
let
  writableMountpoints = [
    "/srv/containers"
    "/srv/media"
    "/srv/backups"
    "/srv/games"
  ];
in
{
  users.groups.zfsmnt = { };
  users.users.${username}.extraGroups = [ "zfsmnt" ];
  systemd.tmpfiles.rules = map (mp: "d ${mp} 2775 root zfsmnt - -") writableMountpoints;

  ########################################
  # Snapshot policy (sanoid)
  ########################################
  services.sanoid = {
    enable = true;
    templates.keep = {
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 3;
      autosnap = true;
      autoprune = true;
    };
    datasets = {
      "ssd/containers" = {
        useTemplate = [ "keep" ];
      };
    };
  };

  disko.devices = {
    zpool = {
      # SSD mirror for ssd storage
      ssd = {
        datasets = {
          "containers" = {
            type = "zfs_fs";
            options = {
              recordsize = "16K";
              quota = "100GB";
              mountpoint = "/srv/containers";
            };
          };
          "games" = {
            type = "zfs_fs";
            options = {
              recordsize = "32K";
              quota = "200GB";
              mountpoint = "/srv/games";
            };
          };
          "llm" = {
            type = "zfs_fs";
            options = {
              recordsize = "32K";
              quota = "100GB";
              mountpoint = "/srv/llm";
            };
          };
        };
      };

      # HDD mirror for data/backup/archives
      hdd = {
        datasets = {
          "backups" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/srv/backups";
              quota = "100GB";
            };
          };
          "media" = {
            type = "zfs_fs";
            options = {
              recordsize = "1M";
              quota = "500GB";
              mountpoint = "/srv/media";
            };
          };
        };
      };
    };
  };
}
