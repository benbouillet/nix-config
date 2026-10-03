{ ... }:
{
  services = {
    smartd = {
      enable = true;
      autodetect = true;
    };
    fstrim.enable = true;
  };

}
