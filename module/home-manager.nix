{pkgs, config, lib, ...}: {
  # add home-manager user settings here
  home.packages = with pkgs; [
    git
    neovim
    tree
    zsh-vi-mode
    nerdfonts
    ripgrep
  ];
  home.stateVersion = "23.11";
  home.activation = {
    aliasHomeManagerApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      app_folder="${config.home.homeDirectory}/Applications/Home Manager Trampolines"
      rm -rf "$app_folder"
      mkdir -p "$app_folder"
      find "$genProfilePath/home-path/Applications" -type l -print | while read -r app; do
          app_target="$app_folder/$(basename "$app")"
          real_app="$(readlink "$app")"
          echo "mkalias \"$real_app\" \"$app_target\"" >&2
          $DRY_RUN_CMD ${pkgs.mkalias}/bin/mkalias "$real_app" "$app_target"
      done
    '';
  };

  programs = {
    alacritty = {
      enable = true;
      settings = ''
env = {
  XTERM = "xterm-256color";
  TERM = "alacritty";
}
      '';
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      antidote.enable = true;
      antidote.plugins = [
          "jeffreytse/zsh-vi-mode"
          "davidde/git"
      ];
    };

    git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        user.email = "benbouillet@protonmail.com";
        user.name = "Ben Bouillet";
      };
      aliases = {
        gst = "status";
      };
    };
  };
}
