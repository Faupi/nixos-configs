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
    home.packages = with pkgs; [
      plasma-drawer
    ];

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
            name = "p-connor.plasma-drawer"; # req: pkgs.plasma-drawer
            config = {
              General = {
                useCustomButtonImage = true;
                customButtonImage = cfg.launcherIcon;
                backgroundType = "theme";
                backgroundOpacity = 75;
                disableAnimations = false;
                animationSpeedMultiplier = 1;

                showSearch = true;
                searchIconSize = 32;

                maxNumberColumns = 5;
                appIconSize = 128;
                useDirectoryIcons = false;

                showSystemActions = true;
                showSystemActionLabels = true;
                favoriteSystemActions = "shutdown,reboot,logout,suspend,lock-screen";
                systemActionsUsePlasmaIcons = true;
                systemActionIconSize = 48;
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
                  "org.kde.plasma.brightness"
                  "org.kde.kdeconnect"
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
              displayStyle = "org.kde.ksysguard.barchart";
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
