{ pkgs }:
let
  version = "1.9.0";
  go =
    (pkgs.stdenvNoCC.mkDerivation {
      pname = "go";
      version = "1.27.4";
      src = pkgs.fetchurl {
        url = "https://go.dev/dl/go1.27.4.linux-amd64.tar.gz";
        hash = "sha256-ciZzbCM5cZzaKPvzpU1xqmO87+N26YzvAANCaNqySEA=";
      };
      sourceRoot = "go";
      installPhase = ''
        mkdir -p $out/lib $out/bin
        cp -a . $out/lib/go
        ln -s $out/lib/go/bin/go $out/bin/go
      '';
    })
    // {
      CGO_ENABLED = 0;
      GOOS = "linux";
      GOARCH = "amd64";
    };
in
(pkgs.buildGoModule.override { inherit go; }) {
  pname = "tailmux";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "GrowlyX";
    repo = "tailmux";
    rev = "19444d4630f864ea53b42ce91366431927e78217";
    hash = "sha256-Qi+f86StUlIQt+l9zANm0eUnbmbVo0gHjPNhaibtIFw=";
  };

  vendorHash = "sha256-cCdGBcJhZp+8hdMaayeGDiGPw8HHarS3YevNOZdwiVc=";

  subPackages = [ "cmd/tailmux" ];
  env.CGO_ENABLED = "0";
  env.GOTOOLCHAIN = "local";
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
    "-X main.selfUpdate=off"
  ];

  doCheck = false;

  meta = {
    description = "CLI proxy for accessing Tailnet services";
    homepage = "https://github.com/GrowlyX/tailmux";
    license = pkgs.lib.licenses.mit;
    mainProgram = "tailmux";
    platforms = [ "x86_64-linux" ];
  };
}
