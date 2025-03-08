{ lib, pkgs, ... }@args:
let
  inherit (import ./mkSearchProvider.nix args) mkSearchProvider;
in
{
  programs.plasma.configFile = {
    krunnerrc = {
      General = {
        FreeFloating = true; # Set KRunner to the center of the screen
        ActivityAware = true;
        HistoryEnabled = true;
        RetainPriorSearch = true;
      };
      Plugins = {
        baloosearchEnabled = true;
        locationsEnabled = true;
        krunner_webshortcutsEnabled = true;
        recentdocumentsEnabled = false; # Nix store will force itself there 24/7 otherwise (despite indexing filters)
      };
    };

    kuriikwsfilterrc = {
      General = {
        EnableWebShortcuts = true;
        DefaultWebShortcut = "unduck";
        KeywordDelimiter = ''\s'';
        PreferredWebShortcuts = "u";
        UsePreferredWebShortcutsOnly = false;
      };
    };
  };

  # Disable all default web search providers
  xdg.dataFile."disable-web-shortcuts-defaults" = {
    target = "kf6/searchproviders";
    source = "${(toString (import ./disable-web-shortcuts-defaults.nix args).out)}/share/kf6/searchproviders";
    recursive = true;
  };

  # Add custom providers
  home.packages = [
    (mkSearchProvider {
      name = "unduck";
      url = ''https://unduck.link?q=\\{@}'';
      keywords = [ "u" ];
    })
  ];
}
