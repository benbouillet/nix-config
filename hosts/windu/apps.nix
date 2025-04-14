{ pkgs,
  lib,
  hostConfig,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";
    };

    taps = [
      "homebrew/cask"
    ];

    # `brew install`
    brews = [
      "wget" # download tool
      "curl" # no not install curl via nixpkgs, it's not working well on macOS!
    ];

    # `brew install --cask`
    casks = [
        "tresorit"
        "rectangle"
        "macpass"
        "unnaturalscrollwheels"
    # ];
    ] ++ hostConfig.casks;
  };
}
