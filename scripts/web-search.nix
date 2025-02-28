{ pkgs }:

pkgs.writeShellScriptBin "web-search" ''
    declare -A URLS

    URLS=(
      ["🌎 search.raclette.beer"]="https://search.raclette.beer/search?q="
      ["  Google"]="https://www.google.com/search?q="
      ["  NixOS Packages"]="https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query="
      ["  NixOS Options"]="https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query="
      ["  Home Manager"]="https://home-manager-options.extranix.com/?release=release-24.11&query="
      ["🎞️ YouTube"]="https://www.youtube.com/results?search_query="
      ["🦥 Arch Wiki"]="https://wiki.archlinux.org/index.php?search="
    )

    # List for rofi
    gen_list() {
        for key in "''${!URLS[@]}"; do
            echo "$key"
        done
    }

    main() {
      # Pass the list to rofi
      platform=$( (gen_list) | ${pkgs.wofi}/bin/wofi --dmenu --insensitive )

      if [[ -n "$platform" ]]; then
        query=$( (echo ) | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Enter query:")

        if [[ -n "$query" ]]; then
  	  url=''${URLS[$platform]}$query
          xdg-open "$url"
          sleep 0.2
          hyprctl dispatch focuswindow class:firefox
        else
          exit
        fi
      else
        exit
      fi
    }

    main
''
