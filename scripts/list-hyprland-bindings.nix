{ pkgs }:

pkgs.writeShellScriptBin "list-hyprland-bindings" ''
cat ~/.config/hypr/hyprland.conf  |
  awk -F, '
    /bind/ {
      gsub(/bind[dem]+=/,"");
      print $3": "$1"+"$2
    }' |
  sort |
  uniq
''
