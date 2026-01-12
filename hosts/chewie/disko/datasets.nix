{
  username,
  ...
}:
let
  zfsmntGID = 993;
  writableMountpoints = [
    "/srv/containers"
    "/srv/media"
    "/srv/backups"
    "/srv/games"
  ];
in
{
  users.groups.zfsmnt = {
    gid = zfsmntGID;
  };
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
              acltype = "posixacl";
              aclinherit = "passthrough";
              aclmode = "restricted";
              xattr = "sa";
            };
          };
          "games" = {
            type = "zfs_fs";
            options = {
              recordsize = "32K";
              quota = "200GB";
              mountpoint = "/srv/games";
              acltype = "posixacl";
              aclinherit = "passthrough";
              aclmode = "restricted";
              xattr = "sa";
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
              acltype = "posixacl";
              aclinherit = "passthrough";
              aclmode = "restricted";
              xattr = "sa";
            };
          };
          "media" = {
            type = "zfs_fs";
            options = {
              recordsize = "1M";
              quota = "500GB";
              mountpoint = "/srv/media";
              acltype = "posixacl";
              aclinherit = "passthrough";
              aclmode = "restricted";
              xattr = "sa";
            };
          };
          "llm" = {
            type = "zfs_fs";
            options = {
              recordsize = "32K";
              quota = "100GB";
              mountpoint = "/srv/llm";
              acltype = "posixacl";
              aclinherit = "passthrough";
              aclmode = "restricted";
              xattr = "sa";
            };
          };
        };
      };
    };
  };
}
