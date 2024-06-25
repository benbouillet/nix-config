{ ... } : {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "screen-256color";
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    plugins = with pkgs; [
      tmuxPlugins.yank
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.urlview
      tmuxPlugins.tmux-thumbs
      tmuxPlugins.tmux-fzf
      tmuxPlugins.sessionist
      tmuxPlugins.pain-control
      tmuxPlugins.nord
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
    ];
    extraConfig = ''
    set-option -ga terminal-overrides ",xterm-256color:RGB"
    '';
  };
}
