{ pkgs }:
pkgs.rustPlatform.buildRustPackage {
  pname = "pup";
  version = "1.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "DataDog";
    repo = "pup";
    rev = "v1.0.0";
    hash = "sha256-dXVyUYHEREIQHdh6MQm8K0x3VNa8VQotuYLuqV8e+Kw=";
  };

  cargoHash = "sha256-fCxhipOYTt5X9H4njScL5N+rjqceJMv8wzcJhbxW5Q4=";

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
