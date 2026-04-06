{ pkgs }:
let
  version = "0.22.0";
in
  pkgs.stdenv.mkDerivation {
  pname = "auggie";
  version = version;

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@augmentcode/auggie/-/auggie-${version}.tgz";
    hash = "sha512-zAFBQj9xnBRkuFTwp02Sg6C8wYuUN2v8L9AJEDDGXYJfxgjdfn6rEbpxD7KAS46wOQXh3d6C93QHC0gNsihuTA==";
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
