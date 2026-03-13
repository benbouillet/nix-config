{
  pkgs,
}:
let
  nodePkgs = import ./. {
    inherit pkgs;
    inherit (pkgs) system;
    nodejs = pkgs.nodejs;
  };
in
nodePkgs."@augmentcode/auggie"
