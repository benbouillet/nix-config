{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "auggie";
  version = "0.19.0";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@augmentcode/auggie/-/auggie-0.19.0.tgz";
    hash = "sha512-N3LdAOKk8TeAtUB+oZJwYKzp5d0p0dGVfN9gW+qFxOzGg8vGS0uS72hKtgpKoCuDB2adYSS5i5CjDw+apD95qg==";
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
