{ pkgs }:
pkgs.writeShellScriptBin "list-hyprland-bindings" ''
  gen_bindings_list() {
    cat ~/.config/hypr/hyprland.lua |
    awk '
      /^hl\.bind\(/ {
        if (match($0, /hl\.bind\("([^"]*)"/, m)) key = m[1]
        next
      }
      /\["description"\] = / {
        if (key != "" && match($0, /\["description"\] = "([^"]*)"/, m))
          print m[1] ": " key
        key = ""
      }
    ' |
    sort |
  uniq |
  ${pkgs.tofi}/bin/tofi --width "70%" --fuzzy-match false --prompt-text "Shortcut:"
  }

  gen_bindings_list
''
