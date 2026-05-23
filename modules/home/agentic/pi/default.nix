{ pkgs, ... }:
let
  little-coder = pkgs.buildNpmPackage {
    pname = "little-coder";
    version = "1.4.1";

    src = pkgs.fetchFromGitHub {
      owner = "itayinbarr";
      repo = "little-coder";
      rev = "55a83528985ed590df82cca2c478b0f206209500";
      hash = "sha256-T/wHDTMsh2H2dWP1pI1fdP8e/zrSl/QZ2du7ixhxM+Y=";
    };

    npmDepsHash = "sha256-s1t5PVblis4T/Fv8WIiPKwSjmY9ZeE5bJbE2fdIL9jA=";

    dontNpmBuild = true;
  };

  pi-vim-src = pkgs.runCommand "pi-vim-0.3.2" { } ''
    mkdir -p $out
    tar -xzf ${pkgs.fetchurl {
      url = "https://registry.npmjs.org/pi-vim/-/pi-vim-0.3.2.tgz";
      hash = "sha256-QOZ4a7VD5MgihJZHJU4QGx3oW4lsul+9bVmYyUlknxg=";
    }} --strip-components=1 -C $out
  '';

  little-coder-with-extensions = pkgs.symlinkJoin {
    name = "little-coder-with-extensions";
    paths = [ little-coder ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/little-coder \
        --add-flags "--extension ${pi-vim-src}/index.ts"
    '';
  };
in
{
  home.sessionVariables = {
    # Extra bash commands allowed by little-coder's permission-gate.
    # Trailing space = word boundary ("make " allows `make test` but not `makefoo`).
    LITTLE_CODER_BASH_ALLOW = "nix-prefetch-url ,nix hash to-sri ";
  };

  home.packages = [
    pkgs.nodejs
    little-coder-with-extensions
  ];

  home.file.".npmrc".text = ''
    prefix=''${HOME}/.npm-global
  '';
  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  home.file.".pi/agent/settings.json" = {
    source = ./settings.json;
    force = true;
  };
}
