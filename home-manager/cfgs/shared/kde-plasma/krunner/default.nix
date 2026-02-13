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
          calculatorEnabled = true;
          helprunnerEnabled = true;
          krunner_kwinEnabled = true;
          krunner_powerdevilEnabled = true;
          krunner_servicesEnabled = true;
          krunner_shellEnabled = true;
          krunner_systemsettingsEnabled = true;
          unitconverterEnabled = true;
          windowsEnabled = true;

          baloosearchEnabled = false;
          browserhistoryEnabled = false;
          browsertabsEnabled = false;
          krunner_appstreamEnabled = false;
          krunner_bookmarksrunnerEnabled = false;
          krunner_charrunnerEnabled = false;
          krunner_dictionaryEnabled = false;
          krunner_katesessionsEnabled = false;
          krunner_killEnabled = false;
          krunner_konsoleprofilesEnabled = false;
          krunner_placesrunnerEnabled = false;
          krunner_plasma-desktopEnabled = false;
          krunner_recentdocumentsEnabled = false;
          krunner_sessionsEnabled = false;
          krunner_spellcheckEnabled = false;
          krunner_webshortcutsEnabled = false;
          locationsEnabled = false;
          "org.kde.activities2Enabled" = false;
          "org.kde.datetimeEnabled" = false;
          recentdocumentsEnabled = false;
        };
        "Plugins/Favorites" = {
          plugins = lib.strings.concatStringsSep "," [
            "windows" # Windows
            "krunner_services" # Applications
            "krunner_systemsettings" # System Settings
          ];
        };
      };
    };

    # Autostart KRunner so there's no waiting for the initial request
    home.packages = [
      (pkgs.makeAutostartItem rec {
        name = "krunner";
        package = pkgs.makeDesktopItem {
          inherit name;
          desktopName = "KRunner";
          exec = "systemctl --user start plasma-krunner.service";
          extraConfig = {
            OnlyShowIn = "KDE";
          };
        };
      })
    ];

    # Adjust the default service to allow it to be more prioritized
    xdg.configFile."systemd/user/plasma-krunner.service.d/override.conf".text = lib.generators.toINI { } {
      Service = {
        CPUWeight = 1000;
      };
    };
  };
}
