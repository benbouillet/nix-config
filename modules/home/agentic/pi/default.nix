{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.pi-coding-agent
    pkgs.nodejs
  ];

  # npm install -g needs a writable prefix; Nix store is read-only
  home.file.".npmrc".text = ''
    prefix=''${HOME}/.npm-global
  '';
  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  # Pi does NOT follow XDG — everything goes under ~/.pi/agent/

  # settings.json — declares npm/git packages for pi to auto-install.
  # Add entries under "packages"; pin versions for reproducibility.
  home.file.".pi/agent/settings.json" = {
    source = ./settings.json;
    force = true;
  };

  # Custom extensions — add .ts files under ./extensions/.
  # Pi auto-discovers from ~/.pi/agent/extensions/*.ts and */index.ts.
  # Supports /reload hot-reloading when running interactively.
  # home.file.".pi/agent/extensions/web-search.ts" = {
  #   source = ./extensions/web-search.ts;
  #   force = true;
  # };
}
