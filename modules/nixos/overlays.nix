{
  nixpkgs.overlays = [
    (final: prev: {
      bambu-studio =
        let
          pname = "bambu-studio";
          version = "02.06.01.55";
          ubuntu_version = "ubuntu24.04-v${version}-20260429100944";
          src = prev.fetchurl {
            url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/BambuStudio_${ubuntu_version}.AppImage";
            hash = "sha256-TEFQeN2Wy3IlhzDM61w299CusvJLYpEiFpQndIvFbDw=";
          };
        in
        prev.appimageTools.wrapType2 {
          name = "BambuStudio";
          inherit pname version src;

          profile = ''
            export SSL_CERT_FILE="${prev.cacert}/etc/ssl/certs/ca-bundle.crt"
            export GIO_MODULE_DIR="${prev.glib-networking}/lib/gio/modules/"
          '';

          extraPkgs = pkgs: with pkgs; [
            cacert
            glib
            glib-networking
            gst_all_1.gst-plugins-bad
            gst_all_1.gst-plugins-base
            gst_all_1.gst-plugins-good
            webkitgtk_4_1
          ];

          extraInstallCommands =
            let
              contents = prev.appimageTools.extractType2 { inherit pname version src; };
            in
            ''
              install -Dm444 ${contents}/BambuStudio.desktop $out/share/applications/BambuStudio.desktop
              substituteInPlace $out/share/applications/BambuStudio.desktop \
                --replace-warn 'Exec=AppRun' 'Exec=bambu-studio'
              cp -r ${contents}/usr/share/icons $out/share/
            '';
        };
    })
  ];
}
