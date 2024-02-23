{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.programs.plasma;
in
{
  options.programs.plasma = {
    # Very much optional helper option to override the launcher icons
    launcherIcon = mkOption {
      type = with types; nullOr str;
      default = null;
    };
  };

  config = {
    programs.plasma.panels = [
      {
        location = "bottom";
        hiding = "none";
        alignment = "center";
        height = 44;
        widgets = [
          {
            name = "org.kde.plasma.kickoff";
            config = mkMerge [
              {
                General = {
                  favorites = concatStringsSep "," [
                    "preferred://browser"
                    "preferred://filemanager"
                    "org.kde.konsole.desktop"
                    "org.kde.discover.desktop"
                    "org.kde.plasma-systemmonitor.desktop"
                    "systemsettings.desktop"
                  ];

                  # "Highlight" session buttons
                  # NOTE: Needs 2 backslashes for some ungodly reason
                  systemFavorites = concatStringsSep "\\\\," [
                    "lock-screen"
                    "logout"
                    "save-session"
                  ];
                  primaryActions = toString 1;
                };
              }

              (mkIf (cfg.launcherIcon != null)
                {
                  General.icon = cfg.launcherIcon;
                }
              )
            ];
          }

          {
            name = "org.kde.plasma.pager";
            config = {
              General = {
                displayedText = "Number";
                showWindowIcons = true;
              };
            };
          }

          "org.kde.plasma.panelspacer"

          {
            name = "org.kde.plasma.icontasks";
            config = {
              General = {
                maxStripes = toString 1;
                groupedTaskVisualization = toString 1; # Click on group shows previews
                launchers = concatStringsSep "," [
                  "preferred://filemanager"
                  "preferred://browser"
                  "1password.desktop"
                ];
              };
            };
          }

          "org.kde.plasma.panelspacer"

          "org.kde.plasma.systemtray" # Config below

          {
            name = "org.kde.plasma.digitalclock";
            config = {
              Appearance = {
                use24hFormat = toString 2; # Force 24h format specifically
                dateFormat = "isoDate"; # ISO date - 2023-08-23
              };
            };
          }

          {
            name = "org.kde.plasma.systemmonitor";
            config = {
              Appearance = {
                chartFace = "org.kde.ksysguard.horizontalbars";
              };
              Sensors = {
                highPrioritySensorIds = strings.escape [ ''"'' ] (# Is put into a JS script in double quotes, needs escaping
                  generators.toJSON { } [
                    "cpu/all/usage"
                    "memory/physical/usedPercent"
                    "memory/swap/usedPercent"
                  ]
                );
              };
              SensorColors = {
                "cpu/all/usage" = "37,179,189";
                "memory/physical/usedPercent" = "147,37,189";
                "memory/swap/usedPercent" = "37,189,53";
              };
            };
          }
        ];

        # Extra JS
        extraSettings = readFile (pkgs.substituteAll {
          src = ./system-tray.js;

          shownItems = concatStringsSep "," [
            "org.kde.plasma.battery"
            "org.kde.plasma.volume"
            "org.kde.plasma.keyboardlayout"
          ];
          hiddenItems = concatStringsSep "," [
            "org.kde.kalendar.contact"
            "org.kde.plasma.clipboard"
            "org.kde.kscreen"
            "Discover Notifier_org.kde.DiscoverNotifier"
            "Wallet Manager"
            "KDE Daemon"
            "The KDE Crash Handler"
          ];
        });
      }
    ];
  };
}
