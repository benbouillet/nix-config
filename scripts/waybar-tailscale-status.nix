{ pkgs }:

pkgs.writeShellScriptBin "waybar-tailscale-status" ''

  main() {
    STATUS=$(tailscale status --peers=false)
    if [ $? = 0 ]
    then
      text="󱇱 "
      tooltip=$(echo $STATUS | awk '{print "Tailscale connected\\n"$2" - "$1}')
    else
      text="󱇲 "
      tooltip="Tailscale disconnected"
    fi
  
    echo "{\"text\":\"$text\", \"tooltip\":\"$tooltip\"}"
  }

  main
''
