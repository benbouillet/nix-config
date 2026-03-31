{ ... }:
let
  globals = {
    # domain = "r4clette.com";
    domain = "leia.r4clette.com";
    ports = {
      prometheus_exporters = {
        node = 9000;
        zfs = 9116;
      };
    };
  };
in
{
  _module.args.globals = globals;
}
