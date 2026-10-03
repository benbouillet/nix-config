{ pkgs }:
let
  version = "2026.6.1";
  src = pkgs.fetchurl {
    url = "https://github.com/betaflight/betaflight-configurator/releases/download/${version}/betaflight-${version}-amd64.AppImage";
    hash = "sha256-oXd5EgEa4cg8Qt6u74w043zeAyUbMqS64z7VsvWjpe8=";
  };
  appimageContents = pkgs.appimageTools.extract {
    pname = "betaflight-configurator";
    inherit version src;
  };
in
pkgs.appimageTools.wrapType2 {
  pname = "betaflight-configurator";
  inherit version src;
  # Desktop entry Exec=betaflight-app
  executableName = "betaflight-app";

  nativeBuildInputs = [ pkgs.makeWrapper ];

  extraInstallCommands = ''
    mkdir -p $out/share/applications $out/share/icons/hicolor/128x128/apps
    install -m444 ${appimageContents}/usr/share/applications/Betaflight.desktop $out/share/applications/Betaflight.desktop
    install -m444 ${appimageContents}/usr/share/icons/hicolor/128x128/apps/betaflight-app.png $out/share/icons/hicolor/128x128/apps/betaflight-app.png

    # https://github.com/betaflight/betaflight-configurator/issues/5375
    # The AppImage bundles an incompatible libwayland-client; LD_PRELOAD the system one.
    real="$(readlink -f "$out/bin/betaflight-app")"
    rm "$out/bin/betaflight-app"
    makeWrapper "$real" "$out/bin/betaflight-app" \
      --prefix LD_PRELOAD : ${pkgs.wayland}/lib/libwayland-client.so.0
  '';

  meta = {
    description = "Configuration and management application for Betaflight flight controllers";
    homepage = "https://betaflight.com";
    license = pkgs.lib.licenses.gpl3;
    mainProgram = "betaflight-app";
    platforms = [ "x86_64-linux" ];
  };
}
