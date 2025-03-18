{
  pkgs,
  lib,
  host,
  ...
}:
let
  inherit (import ../hosts/${host}/variables.nix)
    terminal
    ;
in
with lib;
{
  home.packages = with pkgs; [
    swayosd
  ];

  wayland.windowManager.hyprland = {
    settings =
      let
        modifier = "SUPER";
      in
      {
        bindlde = [
          ",XF86AudioRaiseVolume,Increase Volume,exec,swayosd-client --output-volume +5 --max-volume=100"
          ",XF86AudioLowerVolume,Decrease Volume,exec,swayosd-client --output-volume -5"
          "${modifier},XF86AudioRaiseVolume,Increase Input Volume,exec,swayosd-client --input-volume +5 --max-volume=100"
          "${modifier},XF86AudioLowerVolume,Decrease Input Volume,exec,swayosd-client --input-volume -5"
        ];
        bindld = [
          ",XF86MonBrightnessUp,Increase Brightness,exec,swayosd-client --brightness raise 5%+"
          ",XF86MonBrightnessDown,Decrease Brightness, exec, swayosd-client --brightness lower 5%-"
          "${modifier}, XF86MonBrightnessUp,Set Brightness to 100%,exec, brightnessctl set 100%"
          "${modifier}, XF86MonBrightnessDown,Set Brightness to 0%, exec, brightnessctl set 0%"
        ];
        bindd = [
          ",XF86AudioMute,Mute,exec, swayosd-client --output-volume mute-toggle"
          ",XF86AudioMicMute,Mute,exec, swayosd-client --input-volume mute-toggle"
          "${modifier},Return,Open ${terminal},exec,${terminal}"
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
          "${modifier}ALT,H,Resize Active Window Left,resizeactive,-30 0"
          "${modifier}ALT,L,Resize Active Window Right,resizeactive,30 0"
          "${modifier}ALT,K,Resize Active Window Down,resizeactive,0 -30"
          "${modifier}ALT,J,Resize Active Window Up,resizeactive,0 30"
        ];
      };
  };
}
