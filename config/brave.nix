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
    # extraOpts = {
    #   BookmarkBarEnabled = false;
    #   BrowserSignin = 0;
    #   DefaultBrowserSettingEnabled = false;
    #   DefaultSearchProviderEnabled = true;
    #   DefaultSearchProviderSearchURL = "https://search.raclette.beer/?q={searchTerms}";
    #   HighContrastEnabled = true;
    #   ImportBookmarks = false;
    #   PasswordManagerEnabled = false;
    #   ShowAppsShortcutInBookmarkBar = false;
    #   SyncDisabled = true;
    # };
  };
}
