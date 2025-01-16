{ pkgs }:

pkgs.writeShellScriptBin "waybar-tailscale-updown" ''

  main() {
    tailscale status --peers=false 1>/dev/null
    if [ $? = 0 ]
    then
      tailscale down
    else
      tailscale up
    fi
  }

  main
''
