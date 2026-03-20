{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "auggie";
  version = "0.20.1";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@augmentcode/auggie/-/auggie-0.20.1.tgz";
    hash = "sha512-n+Bt9yloiRlEIELuy9oIyZILndqS4HKtwzc5ECG+EKdsslTv7aYV3L1X3PTF93/YPtxNplMilSzalzJrQwzpyg==";
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
