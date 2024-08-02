{ config, pkgs, lib, sharedOptions, ... }:
with lib;
let
  cfg = config.programs.plasma;
in
{
  options.programs.plasma = {
    # Very much optional helper option to override the launcher icons
    launcherIcon = mkOption {
      type = with types; nullOr str;
      default = builtins.fetchurl {
        url = "https://github.com/NixOS/nixos-artwork/blob/de03e887f03037e7e781a678b57fdae603c9ca20/logo/nix-snowflake-colours.svg";
        sha256 = "sha256:1cifj774r4z4m856fva1mamnpnhsjl44kw3asklrc57824f5lyz3";
      };
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
                showWindowIcons = "true";
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
                dateDisplayFormat = "BelowTime";
                dateFormat = "custom";
                customDateFormat = "dd/MM/yyyy";
              };
            };
          }

          # TODO: Replace with plasma-manager builder
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
                "cpu/all/usage" = sharedOptions.colorCPU;
                "memory/physical/usedPercent" = sharedOptions.colorMemory;
                "memory/swap/usedPercent" = sharedOptions.colorSwap;
              };
              SensorLabels = {
                "cpu/all/usage" = "CPU";
                "memory/physical/usedPercent" = "Memory";
                "memory/swap/usedPercent" = "Swap";
              };
            };
          }
        ];

        # Extra JS
        extraSettings = (readFile (pkgs.substituteAll {
          src = ./system-tray.js;

          scaleIconsToFit = toString false;
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
        }));
      }
    ];
  };
}
