{
  host,
  pkgs,
  lib,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix)
    terminal
    ;
  inherit (lib)
    optionalString
    ;

  inherit (lib.generators)
    mkLuaInline
    ;

  toLua = lib.generators.toLua { };

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

  mkKey = mods: key: "${optionalString (mods != "") (mods + "+")}${key}";

  mkBind = mods: key: desc: dsp: flags: {
    _args = [
      (mkKey mods key)
      dsp
      (
        flags
        // {
          description = desc;
        }
      )
    ];
  };

  execCmd = cmd: mkLuaInline "hl.dsp.exec_cmd(${toLua cmd})";
  focusDir = dir: mkLuaInline "hl.dsp.focus({ direction = ${toLua dir} })";
  focusWs = ws: mkLuaInline "hl.dsp.focus({ workspace = ${toLua ws} })";
  moveDir = dir: mkLuaInline "hl.dsp.window.move({ direction = ${toLua dir} })";
  moveWs = ws: mkLuaInline "hl.dsp.window.move({ workspace = ${toLua ws} })";
  resizeWin =
    dx: dy:
    mkLuaInline "hl.dsp.window.resize({ x = ${toString dx}, y = ${toString dy}, relative = true })";

  closeWin = mkLuaInline "hl.dsp.window.close()";
  fullscreen = mkLuaInline "hl.dsp.window.fullscreen()";
  toggleFloat = mkLuaInline "hl.dsp.window.float({ action = \"toggle\" })";
  pinWindow = mkLuaInline "hl.dsp.window.pin()";
  cycleNext = mkLuaInline "hl.dsp.window.cycle_next()";
  bringToTop = mkLuaInline "hl.dsp.window.bring_to_top()";
  toggleSplit = mkLuaInline "hl.dsp.layout(\"togglesplit\")";
  toggleSpecial = mkLuaInline "hl.dsp.workspace.toggle_special()";
  moveWindow = mkLuaInline "hl.dsp.window.drag()";
  resizeWindow = mkLuaInline "hl.dsp.window.resize()";

  modifier = "SUPER";
in
{
  wayland.windowManager.hyprland = {
    settings = {
      bind =
        let
          locked = {
            locked = true;
          };
          lockedRepeat = locked // {
            repeating = true;
          };
          release = {
            release = true;
          };
          mouse = {
            mouse = true;
          };
          repeating = {
            repeating = true;
          };
        in
        [
          # bindlde: locked + repeating
          (mkBind "" "XF86AudioRaiseVolume" "Increase Volume"
            (execCmd "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+")
            lockedRepeat
          )
          (mkBind "" "XF86AudioLowerVolume" "Decrease Volume"
            (execCmd "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-")
            lockedRepeat
          )
          (mkBind modifier "XF86AudioRaiseVolume" "Increase Input Volume"
            (execCmd "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SOURCE@ 5%+")
            lockedRepeat
          )
          (mkBind modifier "XF86AudioLowerVolume" "Decrease Input Volume"
            (execCmd "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SOURCE@ 5%-")
            lockedRepeat
          )
          (mkBind "" "XF86AudioPlay" "Play/Pause Media" (execCmd "playerctl play-pause") lockedRepeat)
          (mkBind "" "XF86MonBrightnessUp" "Increase Brightness" (execCmd "brightnessctl set 5%+")
            lockedRepeat
          )
          (mkBind "" "XF86MonBrightnessDown" "Decrease Brightness" (execCmd "brightnessctl set 5%-")
            lockedRepeat
          )
          (mkBind "" "Print" "Push to talk/Mic On" (execCmd "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0")
            lockedRepeat
          )

          # binddr: release
          (mkBind "" "Print" "Push to talk/Mic On" (execCmd "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1")
            release
          )

          # bindld: locked
          (mkBind "${modifier}+SHIFT" "XF86AudioRaiseVolume" "Choose Audio Output" (execCmd "${
            selectOutput
          }") locked)
          (mkBind "${modifier}+SHIFT" "XF86AudioLowerVolume" "Choose Audio Input" (execCmd "${
            selectInput
          }") locked)
          (mkBind modifier "XF86MonBrightnessUp" "Increase Keyboard Brightness"
            (execCmd "brightnessctl --device='framework_laptop::kbd_backlight' set 20%+")
            locked
          )
          (mkBind modifier "XF86MonBrightnessDown" "Decrease Keyboard Brightness"
            (execCmd "brightnessctl --device='framework_laptop::kbd_backlight' set 20%-")
            locked
          )
          (mkBind "" "XF86AudioPrev" "Previous Track" (execCmd "playerctl previous") locked)
          (mkBind "" "XF86AudioNext" "Next Track" (execCmd "playerctl next") locked)
          (mkBind "" "XF86AudioMute" "Mute" (execCmd "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") locked)
          (mkBind modifier "XF86AudioMute" "Mute" (execCmd "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
            locked
          )
          (mkBind modifier "Return" "Open ${terminal}" (execCmd "${terminal}") locked)
          (mkBind modifier "W" "Open Browser" (execCmd "firefox") locked)
          (mkBind "${modifier}+SHIFT" "W" "Open Browser with sundayapp profile"
            (execCmd "firefox -p sundayapp")
            locked
          )
          (mkBind modifier "T" "Open file manager Thunar" (execCmd "thunar") locked)
          (mkBind modifier "N" "Toggle SwayNC" (execCmd "swaync-client -t") locked)
          (mkBind modifier "SPACE" "Launch Tofi" (execCmd "tofi-drun --drun-launch=true") locked)
          (mkBind modifier "Q" "Kill Active Window" closeWin locked)
          (mkBind modifier "P" "Play/Pause Player" (execCmd "playerctl play-pause") locked)
          (mkBind modifier "C" "Color Picker" (execCmd "hyprpicker -a") locked)
          (mkBind "${modifier}+SHIFT" "I" "Toggle Window Split" toggleSplit locked)
          (mkBind modifier "F" "Fullscreen" fullscreen locked)
          (mkBind modifier "E" "Emoji Picker" (execCmd "emoji-picker") locked)
          (mkBind modifier "U" "Shutdown/Restart/Suspend/Hibernate/Lock" (execCmd "wlogout") locked)
          (mkBind "${modifier}+SHIFT" "F" "Toggle Floating Windows" toggleFloat locked)
          (mkBind "${modifier}+SHIFT" "P" "Toggle Pinning Windows" pinWindow locked)
          (mkBind "${modifier}+SHIFT" "Q" "Lock" (execCmd "hyprlock") locked)
          (mkBind "${modifier}+SHIFT" "S" "Display Hyprland Bindings/Shortcuts"
            (execCmd "list-hyprland-bindings")
            locked
          )
          (mkBind "${modifier}+SHIFT" "left" "Move Active Window Left" (moveDir "l") locked)
          (mkBind "${modifier}+SHIFT" "right" "Move Active Window Right" (moveDir "r") locked)
          (mkBind "${modifier}+SHIFT" "up" "Move Active Window Up" (moveDir "u") locked)
          (mkBind "${modifier}+SHIFT" "down" "Move Active Window Down" (moveDir "d") locked)
          (mkBind "${modifier}+SHIFT" "H" "Move Active Window Left" (moveDir "l") locked)
          (mkBind "${modifier}+SHIFT" "L" "Move Active Window Right" (moveDir "r") locked)
          (mkBind "${modifier}+SHIFT" "K" "Move Active Window Up" (moveDir "u") locked)
          (mkBind "${modifier}+SHIFT" "J" "Move Active Window Down" (moveDir "d") locked)
          (mkBind "${modifier}+SHIFT" "V" "Screenshot Active Window (clipboard only)"
            (execCmd "hyprshot -m window -m active --clipboard-only")
            locked
          )
          (mkBind "${modifier}+SHIFT" "B" "Screenshot Region" (execCmd "hyprshot -m region --clipboard-only")
            locked
          )
          (mkBind "${modifier}+SHIFT" "N" "Screenshot Active Window (folder)"
            (execCmd "hyprshot -m window -m active --output-folder $HOME/Downloads")
            locked
          )
          (mkBind "${modifier}+SHIFT" "M" "Screenshot Region (folder)"
            (execCmd "hyprshot -m region --output-folder $HOME/Downloads")
            locked
          )
          (mkBind modifier "left" "Move Focus Left" (focusDir "l") locked)
          (mkBind modifier "right" "Move Focus Right" (focusDir "r") locked)
          (mkBind modifier "up" "Move Focus Up" (focusDir "u") locked)
          (mkBind modifier "down" "Move Focus Down" (focusDir "d") locked)
          (mkBind modifier "H" "Move Focus Left" (focusDir "l") locked)
          (mkBind modifier "L" "Move Focus Right" (focusDir "r") locked)
          (mkBind modifier "K" "Move Focus Up" (focusDir "u") locked)
          (mkBind modifier "J" "Move Focus Left" (focusDir "d") locked)
          (mkBind modifier "1" "Switch to Workspace 1" (focusWs "1") locked)
          (mkBind modifier "2" "Switch to Workspace 2" (focusWs "2") locked)
          (mkBind modifier "3" "Switch to Workspace 3" (focusWs "3") locked)
          (mkBind modifier "4" "Switch to Workspace 4" (focusWs "4") locked)
          (mkBind modifier "5" "Switch to Workspace 5" (focusWs "5") locked)
          (mkBind modifier "6" "Switch to Workspace 6" (focusWs "6") locked)
          (mkBind modifier "7" "Switch to Workspace 7" (focusWs "7") locked)
          (mkBind modifier "8" "Switch to Workspace 8" (focusWs "8") locked)
          (mkBind modifier "9" "Switch to Workspace 9" (focusWs "9") locked)
          (mkBind modifier "0" "Switch to Workspace 10" (focusWs "10") locked)
          (mkBind modifier "S" "Switch to Special Workspace" toggleSpecial locked)
          (mkBind "${modifier}+SHIFT" "1" "Move Active Window to Workspace 1" (moveWs "1") locked)
          (mkBind "${modifier}+SHIFT" "2" "Move Active Window to Workspace 2" (moveWs "2") locked)
          (mkBind "${modifier}+SHIFT" "3" "Move Active Window to Workspace 3" (moveWs "3") locked)
          (mkBind "${modifier}+SHIFT" "4" "Move Active Window to Workspace 4" (moveWs "4") locked)
          (mkBind "${modifier}+SHIFT" "5" "Move Active Window to Workspace 5" (moveWs "5") locked)
          (mkBind "${modifier}+SHIFT" "6" "Move Active Window to Workspace 6" (moveWs "6") locked)
          (mkBind "${modifier}+SHIFT" "7" "Move Active Window to Workspace 7" (moveWs "7") locked)
          (mkBind "${modifier}+SHIFT" "8" "Move Active Window to Workspace 8" (moveWs "8") locked)
          (mkBind "${modifier}+SHIFT" "9" "Move Active Window to Workspace 9" (moveWs "9") locked)
          (mkBind "${modifier}+SHIFT" "0" "Move Active Window to Workspace 10" (moveWs "10") locked)
          (mkBind "${modifier}+CONTROL" "L" "Switch to Next Workspace" (focusWs "e+1") locked)
          (mkBind "${modifier}+CONTROL" "H" "Switch to Previous Workspace" (focusWs "e-1") locked)
          (mkBind "ALT" "Tab" "Cycle On Windows" cycleNext locked)
          (mkBind "ALT" "Tab" "Cycle On Windows" bringToTop locked)
          (mkBind "" "XF86Keyboard" "Cycle Keyboard Backlight"
            (execCmd "brightnessctl --device='tpacpi::kbd_backlight' set $((($(brightnessctl --device='tpacpi::kbd_backlight' get) + 1) % 3))")
            locked
          )

          # bindmd: mouse
          (mkBind modifier "mouse:272" "Move Window" moveWindow mouse)
          (mkBind modifier "mouse:273" "Resize Window" resizeWindow mouse)

          # binded: repeating
          (mkBind "${modifier}+ALT" "H" "Resize Active Window Left" (resizeWin (-200) 0) repeating)
          (mkBind "${modifier}+ALT" "L" "Resize Active Window Right" (resizeWin 200 0) repeating)
          (mkBind "${modifier}+ALT" "K" "Resize Active Window Down" (resizeWin 0 (-100)) repeating)
          (mkBind "${modifier}+ALT" "J" "Resize Active Window Up" (resizeWin 0 100) repeating)
        ];
    };
  };
}
