{ pkgs }:
pkgs.buildNpmPackage {
  pname = "opencode-augment-auth";
  version = "1.0.0";

  src = "${pkgs.fetchFromGitHub {
    owner = "hletrd";
    repo = "augment-opencode";
    rev = "6c27f9aba328464d19f79e2653fdabd62e7d2d91";
    hash = "sha256-dAR8IhB88oO/Ghdt2N3GXxFvzulQ0tygnhtpdokyiKk=";
  }}/plugin";

  npmDepsHash = "sha256-vUp7XPA6z8yvnTPlJVouQJy9KsVRCGT35SYFR3ylaHg=";

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r dist node_modules package.json $out/
    runHook postInstall
  '';

  meta = {
    description = "OpenCode plugin for Augment Code";
    homepage = "https://github.com/hletrd/augment-opencode";
    license = pkgs.lib.licenses.mit;
  };
}
