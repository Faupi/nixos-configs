{ lib, cfg, pkgs, ... }@args:
let
  inherit (import ./mkSearchProvider.nix args) mkSearchProvider;
in
{
  config = lib.mkIf cfg.enable {
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

    home.packages = [
      # Autostart KRunner so there's no waiting for the initial request
      (pkgs.makeAutostartItem rec {
        name = "krunner";
        package = pkgs.makeDesktopItem {
          inherit name;
          desktopName = "KRunner";
          exec = "krunner -d";
          extraConfig = {
            OnlyShowIn = "KDE";
          };
        };
      })

      # Add custom providers
      (mkSearchProvider {
        name = "unduck";
        url = ''https://unduck.link?q=\\{@}'';
        keywords = [ "u" ];
      })
    ];
  };
}
