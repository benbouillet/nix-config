{ pkgs }:
pkgs.rustPlatform.buildRustPackage {
  pname = "pup";
  version = "1.4.1";

  src = pkgs.fetchFromGitHub {
    owner = "DataDog";
    repo = "pup";
    rev = "v1.4.1";
    hash = "sha256-pyKKtd1LRvrZrdEXtlvPPFXgOFOiyB5HL74j35m1ms8=";
  };

  cargoHash = "sha256-1MvuxBR1Y9eRbW+bAMHWxt9ea+HVcmW6Q5vN4U527y0=";

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [ openssl ];

  doCheck = false;

  meta = with pkgs.lib; {
    description = "Datadog CLI tool for managing Datadog resources";
    homepage = "https://github.com/DataDog/pup";
    license = licenses.asl20;
    mainProgram = "pup";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
