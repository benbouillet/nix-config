{ pkgs }:
let
  version = "0.21.0";
in
  pkgs.stdenv.mkDerivation {
  pname = "auggie";
  version = version;

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@augmentcode/auggie/-/auggie-${version}.tgz";
    hash = "sha512-+ksBIlcq5AiqOdGf6rAr+UZ35t44MZ+OBHNCuO22aU5wLOQ+l9C4J4H8h7Z9X3Dp8Vn30Aw42KZ39vs77TqJcA==";
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
