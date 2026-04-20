{ pkgs }:
let
  version = "0.24.0";
in
  pkgs.stdenv.mkDerivation {
  pname = "auggie";
  version = version;

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@augmentcode/auggie/-/auggie-${version}.tgz";
    hash = "sha512-mX2Ov32bOQMclUSMUg8er610U5YfisHtB6RbBTRB5cuyUZRoqypM3RUWXjBskWWtqw62R0FgXTNd5Tsk9Y/55g==";
  };

  sourceRoot = "package";

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/auggie $out/bin
    cp augment.mjs $out/lib/auggie/
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/auggie \
      --add-flags "$out/lib/auggie/augment.mjs"
    runHook postInstall
  '';

  meta = {
    description = "Auggie CLI by Augment Code";
    homepage = "https://augmentcode.com";
    license = pkgs.lib.licenses.unfree;
  };
}
