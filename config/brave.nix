{
  pkgs,
  ...
}:
{
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # sponsor block
      { id = "gebbhagfogifgggkldgodflihgfeippi"; } # return youtube dislike
      { id = "dnhpnfgdlenaccegplpojghhmaamnnfp"; } # augmented steam
      { id = "fdjamakpfbbddfjaooikfcpapjohcfmg"; } # dashlane
    ];
    commandLineArgs = [ ];
  };
}
