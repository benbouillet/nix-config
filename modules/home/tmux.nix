{
  pkgs,
  ...
}:
{
  programs = {
    tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      escapeTime = 10;
      mouse = true;
      keyMode = "vi";
      baseIndex = 1;
      historyLimit = 100000;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavor 'frappe'
            set -g @catppuccin_window_status_style 'rounded'
            set -g @catppuccin_date_time_text '%a %d/%m %H:%M'
          '';
        }
        yank
        jump
        vim-tmux-navigator
        tmux-thumbs
        tmux-fzf
        sessionist
        pain-control
        resurrect
        continuum
      ];
      extraConfig = ''
        # Terminal
        set -g default-terminal "xterm-256color"
        set-option -ga terminal-overrides ",xterm-256color:Tc"

        # Status bar (driven by Catppuccin modules)
        set -g status-position bottom
        set -g status-interval 60

        set -g status-left-length 100
        set -g status-left "#{E:@catppuccin_status_session}"

        set -g status-right-length 100
        set -g status-right "#[fg=default] 🔋 #(cat /sys/class/power_supply/BAT1/capacity)%% "
        set -agF status-right "#{E:@catppuccin_status_date_time}"

        # tmux-thumbs: yank to system clipboard via OSC52 (works over SSH, supported by Ghostty)
        set -g @thumbs-osc52 1
      '';
    };
  };
}
