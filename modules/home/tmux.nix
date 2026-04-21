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

        # tmux-thumbs: yank to system clipboard via OSC52 (works over SSH, supported by Ghostty)
        set -g @thumbs-osc52 1
      '';
    };
    sesh = {
      enable = true;
      enableAlias = true;
      enableTmuxIntegration = true;
      tmuxKey = "s";
      settings = {
        # Default session configuration (table format)
        default_session = {
          windows = [
            "term"
          ];
        };

        # Window layouts that can be reused across sessions
        window = [
          {
            name = "editor";
            startup_command = "nvim -c :Telescope find_files";
          }
          {
            name = "ai";
            startup_command = ''
              augment
            '';
          }
          {
            name = "term";
            startup_command = "ls";
          }
        ];

        # Wildcard config for projects
        wildcard = [
          {
            pattern = "~/dev/**/*";
            windows = [
              "editor"
              "ai"
              "term"
            ];
          }
        ];

        # Session root directories to scan
        root = [
          "~/dev"
        ];

        # Exclude patterns
        exclude = [
          ".git"
          "node_modules"
          ".Trash"
        ];
      };
    };
  };
}
