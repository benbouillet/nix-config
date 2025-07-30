{
  pkgs,
  username,
  ...
}:
{
  home = {
    packages = with pkgs; [
      todo-txt-cli
    ];
    file.".todo/config" = {
      text = ''
export TODO_DIR="/home/${username}/sync/toolbox/todotxt"
      '';
    };
  };
  programs.zsh.shellAliases = {
    "todo" = "${pkgs.todo-txt-cli}/bin/todo.sh";
    "todo shop" = "${pkgs.todo-txt-cli}/bin/todo.sh ls +";
    "todo sunday" = "${pkgs.todo-txt-cli}/bin/todo.sh ls @sunday";
  };

  programs = {
    zsh = {
      shellAliases = {
        tdls = "todo ls @sunday";
      };
    };
  };
}
