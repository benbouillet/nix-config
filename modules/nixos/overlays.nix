let
  bambuddyCa = ''
    -----BEGIN CERTIFICATE-----
    MIIC7jCCAdagAwIBAgIUSnOMMbelEjLmdD+UYjepj3ZMcQcwDQYJKoZIhvcNAQEL
    BQAwHTEbMBkGA1UEAwwSVmlydHVhbCBQcmludGVyIENBMB4XDTI2MDgwNjA5MTEy
    MVoXDTQ2MDgwMTA5MTEyMVowHTEbMBkGA1UEAwwSVmlydHVhbCBQcmludGVyIENB
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhIZsai5oV/jnDUTh9Ym2
    Pzr2uBYLVthO6MfMJ6Y7dojnq7EkQ1DQmN9wabwv5EODOzqFth4g/W4BuDjXctWJ
    WFjX1boGBus9C7W7vp37Kvuo7qr1ezgTtA38UOA6Dsk1ddNIM1tilsg1QBG4b7p5
    96SCny6FmRbr8oj7ehNndiKWHRBbcdomrJF7AW6y+ZujZbVNqAG8GlkyEHMlXwSf
    KZ+rUtWvpv3UBGbF/Qszz02B3O+Pqm+Mt8fegXDq94m8lemnzmaoAAZPj7FnNe0t
    rujnjfGYHYQtQcN3rUWrqCjJN1VlNE6dI9WxqO1IdLKNrUeF485Bfl6v9q2PTudt
    oQIDAQABoyYwJDASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjAN
    BgkqhkiG9w0BAQsFAAOCAQEABKcsc7B2a+kKCf7hYu7R9u188YilLwpsJMVVM0A/
    5F5XEqFUni33vxm1x4B/a+9d6qz7yGKhQZqVqVjQv+CLmgV68WKZIR0B6d05MvUf
    H6SrVEtIHFxTJkGA4DGt31bZ3AbIf212P01j8yGaWke96fMbAjyNPrksbFUOvyVF
    z7yTSQEvjYoMdvWLahLehKQMRcthzaBGtivr/2fKcmg2nw6yMuonrqzBmEfdcWId
    +99Wk99AE9OXJiWM61GIbMAjrezKH74nagNEb9r5hUKtGN4xlMtalVjaUALozV7E
    s1xGhZLP7ldoFtzggumwuiVjtOMh9Wwb7PAHMivZzUlNng==
    -----END CERTIFICATE-----
  '';
in
{
  nixpkgs.overlays = [
    (final: prev: {
      orca-slicer = prev.orca-slicer.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          # Append Bambuddy CA to printer.cer so virual printers work.
          # The trailing newline prevents certs from running together.
          echo >> "$out/share/OrcaSlicer/cert/printer.cer"
          cat <<'EOF_BAMBDY_CA' >> "$out/share/OrcaSlicer/cert/printer.cer"
    ${bambuddyCa}
    EOF_BAMBDY_CA
        '';
      });
    })
    # (final: prev: {
    #   bambu-studio =
    #     let
    #       pname = "bambu-studio";
    #       version = "02.06.01.55";
    #       ubuntu_version = "ubuntu24.04-v${version}-20260429100944";
    #       src = prev.fetchurl {
    #         url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/BambuStudio_${ubuntu_version}.AppImage";
    #         hash = "sha256-TEFQeN2Wy3IlhzDM61w299CusvJLYpEiFpQndIvFbDw=";
    #       };
    #     in
    #     prev.appimageTools.wrapType2 {
    #       name = "BambuStudio";
    #       inherit pname version src;
    #
    #       profile = ''
    #         export SSL_CERT_FILE="${prev.cacert}/etc/ssl/certs/ca-bundle.crt"
    #         export GIO_MODULE_DIR="${prev.glib-networking}/lib/gio/modules/"
    #       '';
    #
    #       extraPkgs =
    #         pkgs: with pkgs; [
    #           cacert
    #           glib
    #           glib-networking
    #           gst_all_1.gst-plugins-bad
    #           gst_all_1.gst-plugins-base
    #           gst_all_1.gst-plugins-good
    #           webkitgtk_4_1
    #         ];
    #
    #       extraInstallCommands =
    #         let
    #           contents = prev.appimageTools.extractType2 { inherit pname version src; };
    #         in
    #         ''
    #           install -Dm444 ${contents}/BambuStudio.desktop $out/share/applications/BambuStudio.desktop
    #           substituteInPlace $out/share/applications/BambuStudio.desktop \
    #             --replace-warn 'Exec=AppRun' 'Exec=bambu-studio'
    #           cp -r ${contents}/usr/share/icons $out/share/
    #         '';
    #     };
    # })
  ];
}
