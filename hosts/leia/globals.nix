{ lib, ... }:
let
  sharedGlobals = (import ../../modules/nixos/globals-shared.nix { })._module.args.globals;
  globals = lib.recursiveUpdate sharedGlobals {
  };
in
{
  _module.args.globals = globals;
}
