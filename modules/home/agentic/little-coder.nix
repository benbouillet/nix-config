{ pkgs, lib, ... }:
{
  home.packages = [
    (pkgs.buildNpmPackage {
      pname = "little-coder";
      version = "1.4.1";

      src = pkgs.fetchFromGitHub {
        owner = "itayinbarr";
        repo = "little-coder";
        rev = "55a83528985ed590df82cca2c478b0f206209500";
        hash = lib.fakeHash;
      };

      npmDepsHash = lib.fakeHash;
    })
  ];
}
