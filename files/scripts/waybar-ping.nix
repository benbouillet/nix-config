{ pkgs }:

pkgs.writeShellScriptBin "waybar-ping" ''

  main() {
    cloudflare_ping=$(ping -c 1 1.1.1.1 | awk -F'=' '/time=/{printf "%.0fms", $NF}')
    
    echo "{\"text\":\"󰅒  $cloudflare_ping\", \"tooltip\":\"cloudflare - 1.1.1.1\"}"
  }

  main
''
