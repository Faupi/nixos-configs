{ lib, cfg, pkgs, ... }:
{
  # imports = [
  #   ./custom-web-shortcuts
  # ];

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
    ];
  };
}
