{
  ...
}:
{
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
          # "games" = {
          #   type = "zfs_fs";
          #   options = {
          #     recordsize = "32K";
          #     quota = "200GB";
          #     mountpoint = "/srv/games";
          #     acltype = "posixacl";
          #     aclinherit = "passthrough";
          #     aclmode = "restricted";
          #     xattr = "sa";
          #   };
          # };
        };
      };

      # HDD mirror for data/backup/archives
      hdd = {
        datasets = {
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
        };
      };
    };
  };
}
