{ ... }:
let
  globals = {
    domain = "r4clette.com";
  };
in
{
  _module.args.globals = globals;
}
