{
  host,
  pkgs,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix)
    terminal
    ;
  selectOutput = pkgs.writeShellScript "select-audio-output" ''
    pw-dump | jq -r '
      .[]
      | select(.info.props["media.class"] == "Audio/Sink")
      | (.id | tostring) + ": " + .info.props["node.description"]
    ' \
    | sort -u \
    | tofi --width "70%" --fuzzy-match true --prompt-text "Select audio output: " \
    | awk -F': ' '{print $1}' \
    | tr -d '\n' \
    | xargs -I{} wpctl set-default {}
  '';
  selectInput = pkgs.writeShellScript "select-audio-input" ''
    pw-dump | jq -r '
      .[]
      | select(.info.props["media.class"] == "Audio/Source")
      | (.id | tostring) + ": " + .info.props["node.description"]
    ' \
    | sort -u \
    | tofi --width "70%" --fuzzy-match true --prompt-text "Select audio input: " \
    | awk -F': ' '{print $1}' \
    | tr -d '\n' \
    | xargs -I{} wpctl set-default {}
  '';
in
{
  wayland.windowManager.hyprland = {
    settings =
      let
        modifier = "SUPER";
      in
      {
        bindlde = [
          ",XF86AudioRaiseVolume,Increase Volume,exec,wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume,Decrease Volume,exec,wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"
          "${modifier},XF86AudioRaiseVolume,Increase Input Volume,exec,wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SOURCE@ 5%+"
          "${modifier},XF86AudioLowerVolume,Decrease Input Volume,exec,wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SOURCE@ 5%-"
          ",XF86AudioPlay,Play/Pause Media,exec,playerctl play-pause"
          ",XF86MonBrightnessUp,Increase Brightness,exec,brightnessctl set 5%+"
          ",XF86MonBrightnessDown,Decrease Brightness,exec,brightnessctl set 5%-"
        ];
        bindd = [
          "${modifier}SHIFT,XF86AudioRaiseVolume,Choose Audio Output,exec,${selectOutput}"
          "${modifier}SHIFT,XF86AudioLowerVolume,Choose Audio Input,exec,${selectInput}"
          "${modifier},XF86AudioPrev,Previous Track,exec,playerctl previous"
          "${modifier},XF86AudioNext,Next Track,exec,playerctl next"
          "${modifier},XF86AudioLowerVolume,Choose Audio Input,exec,${selectInput}"
          ",XF86AudioMute,Mute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          "${modifier},XF86AudioMute,Mute,exec,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          "${modifier},Return,Open ${terminal},exec,${terminal}"
          "${modifier},W,Open Browser,exec,firefox"
          "${modifier}SHIFT,W,Open Browser with sundayapp profile,exec,firefox -p sundayapp"
          "${modifier},T,Open file manager Thunar,exec,thunar"
          "${modifier},N,Toggle SwayNC,exec,swaync-client -t"
          "${modifier},SPACE,Launch Tofi,exec,tofi-drun --drun-launch=true"
          "${modifier},Q,Kill Active Window,killactive"
          "${modifier},P,Play/Pause Player,exec,playerctl play-pause"
          "${modifier},C,Color Picker,exec,hyprpicker -a"
          "${modifier}SHIFT,I,Toggle Window Split,togglesplit"
          "${modifier},F,Fullscreen,fullscreen"
          "${modifier},E,Emoji Picker,exec,emoji-picker"
          "${modifier},U,Shutdown/Restart/Suspend/Hibernate/Lock,exec,wlogout"
          "${modifier}SHIFT,F,Toggle Floating Windows,togglefloating"
          "${modifier}SHIFT,P,Toggle Pinning Windows,pin"
          "${modifier}SHIFT,Q,Lock,exec,hyprlock"
          "${modifier}SHIFT,S,Display Hyprland Bindings/Shortcuts,exec,list-hyprland-bindings"
          "${modifier}SHIFT,left,Move Active Window Left,movewindow,l"
          "${modifier}SHIFT,right,Move Active Window Right,movewindow,r"
          "${modifier}SHIFT,up,Move Active Window Up,movewindow,u"
          "${modifier}SHIFT,down,Move Active Window Down,movewindow,d"
          "${modifier}SHIFT,H,Move Active Window Left,movewindow,l"
          "${modifier}SHIFT,L,Move Active Window Right,movewindow,r"
          "${modifier}SHIFT,K,Move Active Window Up,movewindow,u"
          "${modifier}SHIFT,J,Move Active Window Down,movewindow,d"
          "${modifier}SHIFT,V,Screenshot Active Window (clipboard only),exec,hyprshot -m window -m active --clipboard-only"
          "${modifier}SHIFT,B,Screenshot Region,exec,hyprshot -m region --clipboard-only"
          "${modifier}SHIFT,N,Screenshot Active Window (folder),exec,hyprshot -m window -m active --output-folder $HOME/Downloads"
          "${modifier}SHIFT,M,Screenshot Region (folder),exec,hyprshot -m region --output-folder $HOME/Downloads"
          "${modifier},left,Move Focus Left,movefocus,l"
          "${modifier},right,Move Focus Right,movefocus,r"
          "${modifier},up,Move Focus Up,movefocus,u"
          "${modifier},down,Move Focus Down,movefocus,d"
          "${modifier},H,Move Focus Left,movefocus,l"
          "${modifier},L,Move Focus Right,movefocus,r"
          "${modifier},K,Move Focus Up,movefocus,u"
          "${modifier},J,Move Focus Left,movefocus,d"
          "${modifier},1,Switch to Workspace 1,workspace,1"
          "${modifier},2,Switch to Workspace 2,workspace,2"
          "${modifier},3,Switch to Workspace 3,workspace,3"
          "${modifier},4,Switch to Workspace 4,workspace,4"
          "${modifier},5,Switch to Workspace 5,workspace,5"
          "${modifier},6,Switch to Workspace 6,workspace,6"
          "${modifier},7,Switch to Workspace 7,workspace,7"
          "${modifier},8,Switch to Workspace 8,workspace,8"
          "${modifier},9,Switch to Workspace 9,workspace,9"
          "${modifier},0,Switch to Workspace 10,workspace,10"
          "${modifier},S,Switch to Special Workspace,togglespecialworkspace"
          "${modifier}SHIFT,1,Move Active Window to Workspace 1,movetoworkspace,1"
          "${modifier}SHIFT,2,Move Active Window to Workspace 2,movetoworkspace,2"
          "${modifier}SHIFT,3,Move Active Window to Workspace 3,movetoworkspace,3"
          "${modifier}SHIFT,4,Move Active Window to Workspace 4,movetoworkspace,4"
          "${modifier}SHIFT,5,Move Active Window to Workspace 5,movetoworkspace,5"
          "${modifier}SHIFT,6,Move Active Window to Workspace 6,movetoworkspace,6"
          "${modifier}SHIFT,7,Move Active Window to Workspace 7,movetoworkspace,7"
          "${modifier}SHIFT,8,Move Active Window to Workspace 8,movetoworkspace,8"
          "${modifier}SHIFT,9,Move Active Window to Workspace 9,movetoworkspace,9"
          "${modifier}SHIFT,0,Move Active Window to Workspace 10,movetoworkspace,10"
          "${modifier}CONTROL,L,Switch to Next Workspace,workspace,e+1"
          "${modifier}CONTROL,H,Switch to Previous Workspace,workspace,e-1"
          "ALT,Tab,Cycle On Windows,cyclenext"
          "ALT,Tab,Cycle On Windows,bringactivetotop"
          ",XF86Keyboard,Cycle Keyboard Backlight,exec,brightnessctl --device='tpacpi::kbd_backlight' set $((($(brightnessctl --device='tpacpi::kbd_backlight' get) + 1) % 3))"
        ];
        bindmd = [
          "${modifier},mouse:272,Move Window,movewindow"
          "${modifier},mouse:273,Resize Window,resizewindow"
        ];
        binded = [
          "${modifier}ALT,H,Resize Active Window Left,resizeactive,-200 0"
          "${modifier}ALT,L,Resize Active Window Right,resizeactive,200 0"
          "${modifier}ALT,K,Resize Active Window Down,resizeactive,0 -100"
          "${modifier}ALT,J,Resize Active Window Up,resizeactive,0 100"
        ];
      };
  };
}
