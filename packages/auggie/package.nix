{ pkgs }:
let
  version = "0.23.0";
in
  pkgs.stdenv.mkDerivation {
  pname = "auggie";
  version = version;

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@augmentcode/auggie/-/auggie-${version}.tgz";
    hash = "sha512-BpvKHGsU6E5HXblLi/H5rWrn1Vjahhm4bKlA5Ovl04kcVW5impt03TjHPur9MS5ta3SwCGb7RSOvHJbuAquZ8w==";
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
