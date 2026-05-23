{ pkgs }:
let
  version = "3.0.9";
in
pkgs.stdenv.mkDerivation {
  pname = "runs-on-cli";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://github.com/runs-on/cli/releases/download/v${version}/roc_v${version}_linux_amd64";
    hash = "sha256-CtQjXSszeegXZwZRqBIb8+ZJNo0VLTFOMVelKtUUgSY=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/roc
    runHook postInstall
  '';

  meta = {
    description = "CLI tool for managing and troubleshooting RunsOn CI installations";
    homepage = "https://runs-on.com/guides/cli/";
    license = pkgs.lib.licenses.mit;
    mainProgram = "roc";
    platforms = [ "x86_64-linux" ];
  };
}
