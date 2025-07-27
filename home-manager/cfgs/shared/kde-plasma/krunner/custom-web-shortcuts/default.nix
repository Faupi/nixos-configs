{ lib, cfg, ... }@args:
let
  inherit (import ./mkSearchProvider.nix args) mkSearchProvider;
in
{
  config = lib.mkIf cfg.enable {
    programs.plasma.configFile.kuriikwsfilterrc = {
      General = {
        EnableWebShortcuts = true;
        DefaultWebShortcut = "unduck";
        KeywordDelimiter = ''\s'';
        PreferredWebShortcuts = "u";
        UsePreferredWebShortcutsOnly = false;
      };
    };

    # Disable all default web search providers
    xdg.dataFile."disable-web-shortcuts-defaults" = {
      target = "kf6/searchproviders";
      source = "${(toString (import ./disable-web-shortcuts-defaults.nix args).out)}/share/kf6/searchproviders";
      recursive = true;
    };

    home.packages = [
      # Add custom providers
      (mkSearchProvider {
        name = "unduck";
        url = ''https://unduck.link?q=\\{@}'';
        keywords = [ "u" ];
      })
    ];
  };
}
