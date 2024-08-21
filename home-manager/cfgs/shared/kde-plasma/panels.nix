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
      default = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    };
  };

  config = {
    programs.plasma.panels = [
      {
        location = "bottom";
        floating = true;
        hiding = "none";
        alignment = "center";
        screen = 0;
        height = 44;
        widgets = [
          {
            kickoff = {
              icon = cfg.launcherIcon;
              showButtonsFor = "power";
              settings = {
                General = {
                  favorites = concatStringsSep "," [
                    "preferred://browser"
                    "preferred://filemanager"
                    "org.kde.konsole.desktop"
                    "org.kde.discover.desktop"
                    "org.kde.plasma-systemmonitor.desktop"
                    "systemsettings.desktop"
                  ];
                };
              };
            };
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
            iconTasks = {
              launchers = [
                "preferred://filemanager"
                "preferred://browser"
              ];
              appearance = {
                showTooltips = true;
                highlightWindows = true;
                indicateAudioStreams = true;
                fill = true;
                rows = {
                  multirowView = "never";
                };
                iconSpacing = "medium";
              };
              behavior = {
                grouping = {
                  method = "none";
                };
                middleClickAction = "newInstance";
                showTasks = {
                  onlyInCurrentScreen = false;
                  onlyInCurrentDesktop = true;
                  onlyInCurrentActivity = true;
                  onlyMinimized = false;
                };
                unhideOnAttentionNeeded = true;
                newTasksAppearOn = "right";
              };
            };
          }

          "org.kde.plasma.panelspacer"

          {
            systemTray = {
              icons = {
                spacing = "medium";
                scaleToFit = false;
              };
              items = {
                showAll = false;
                shown = [
                  "org.kde.plasma.battery"
                  "org.kde.plasma.volume"
                  "org.kde.plasma.keyboardlayout"
                ];
                hidden = [
                  "org.kde.kalendar.contact"
                  "org.kde.plasma.clipboard"
                  "org.kde.kscreen"
                  "org.kde.plasma.devicenotifier"
                  "Discover Notifier_org.kde.DiscoverNotifier"
                  "Wallet Manager"
                  "KDE Daemon"
                  "The KDE Crash Handler"
                  "touchpad"
                  "spotify-client"
                ];
              };
            };
          }

          {
            digitalClock = {
              time = {
                showSeconds = "onlyInTooltip";
                format = "24h";
              };
              date = {
                enable = true;
                format = { custom = "dd/MM/yyyy"; };
                position = "belowTime";
              };
              calendar = {
                firstDayOfWeek = "monday";
                # TODO: Add calendar plugins?
              };
            };
          }

          {
            systemMonitor = {
              displayStyle = "org.kde.ksysguard.horizontalbars";
              title = "System Resources";
              showTitle = true;
              showLegend = true;
              sensors = [
                {
                  name = "cpu/all/usage";
                  color = sharedOptions.colorCPU;
                  label = "CPU";
                }
                {
                  name = "gpu/all/usage";
                  color = sharedOptions.colorGPU;
                  label = "GPU";
                }
                {
                  name = "memory/physical/usedPercent";
                  color = sharedOptions.colorMemory;
                  label = "Memory";
                }
                {
                  name = "memory/swap/usedPercent";
                  color = sharedOptions.colorSwap;
                  label = "Swap";
                }
              ];
            };
          }
        ];
      }
    ];
  };
}
