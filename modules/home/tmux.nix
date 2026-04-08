{
  pkgs,
  ...
}:
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    escapeTime = 10;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    historyLimit = 100000;
    plugins = with pkgs.tmuxPlugins; [
      yank
      jump
      vim-tmux-navigator
      tmux-thumbs
      tmux-fzf
      sessionist
      pain-control
      resurrect
      continuum
      jump
    ];
    extraConfig = ''
      # Opacity
      set -g default-terminal "xterm-256color"
      set-option -ga terminal-overrides ",xterm-256color:Tc"

      # Status bar layout (powerline-style, colors from Stylix)
      set -g status-justify left
      set -g status-position bottom
      set -g status-interval 60

      # Left: session name
      set -g status-left-length 30
      set -g status-left '#[bold] #S #[nobold]'

      # Right: battery, date, time
      set -g status-right-length 60
      set -g status-right '#[fg=default] 🔋 #(cat /sys/class/power_supply/BAT1/capacity)%%  %a %d/%m  %H:%M '

      # Window tabs
      set -g window-status-format ' #I:#W '
      set -g window-status-current-format '#[bold] #I:#W '

      # Hop-like jump shortcut
      set -g @jump-key 's'
    '';
  };
}
