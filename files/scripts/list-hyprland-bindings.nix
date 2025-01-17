{ pkgs }:

pkgs.writeShellScriptBin "list-hyprland-bindings" ''
    gen_bindings_list() {
      cat ~/.config/hypr/hyprland.conf  |
      awk -F, '
        /bind/ {
          gsub(/bind[dem]+=/,"");
          print $3": "$1"+"$2
        }' |
      sort |
    uniq |
    ${pkgs.wofi}/bin/wofi --dmenu --insensitive --prompt "Search for shortcut"
    }

    gen_bindings_list
''
