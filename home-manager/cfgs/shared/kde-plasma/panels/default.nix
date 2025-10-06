{ config, pkgs, lib, cfg, sharedOptions, ... }:
with lib;
let
  hasMonitorSwitcher = attrsets.hasAttrByPath [ "systemd" "user" "services" "monitor-input-switcher" ] config;
in
{
  # Very much optional helper option to override the launcher icons
  options.flake-configs.plasma.launcherIcon = mkOption {
    type = with types; nullOr str;
    default = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      plasma-drawer
      kara
      kde.plasmoid-button
    ];

    programs.plasma.panels =
      let
        topBar = {
          location = "top";
          floating = false;
          hiding = "none";
          alignment = "center";
          opacity = "opaque";
          screen = 0;
          height = 28;
          lengthMode = "fill";
          widgets = [
            /* TODO: Unearth for touch mode
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
            */

            {
              kickoff = {
                icon = cfg.launcherIcon;
                sidebarPosition = "left";
                showActionButtonCaptions = false;
                showButtonsFor.custom = [
                  "suspend"
                  "lock-screen"
                  "logout"
                ];
              };
            }

            {
              name = "org.dhruv8sh.kara";
              config = {
                # NOTE: lowercase "general"
                general = {
                  type = 0; # Pills
                  animationDuration = 200; # ms
                };
                type1 = {
                  t1activeWidth = 20;
                  t1activeHeight = 10;
                  t1height = 10;
                  t1width = 10;
                };
              };
            }

            "org.kde.plasma.panelspacer"

            {
              systemMonitor = {
                displayStyle = "org.kde.ksysguard.horizontalbars";
                title = "System Resources - Processing";
                showTitle = true;
                showLegend = true;
                settings = {
                  "org.kde.ksysguard.horizontalbars/General" = {
                    rangeAuto = false;
                    rangeFrom = 0;
                    rangeTo = 100;
                  };
                };
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
                ];
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
                  position = "besideTime";
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
                title = "System Resources - Memory";
                showTitle = true;
                showLegend = true;
                settings = {
                  "org.kde.ksysguard.horizontalbars/General" = {
                    rangeAuto = false;
                    rangeFrom = 0;
                    rangeTo = 100;
                  };
                };
                sensors = [
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

            "org.kde.plasma.panelspacer"

            (mkIf hasMonitorSwitcher {
              name = "com.github.configurable_button";
              config = {
                onScriptEnabled = true;
                onScript = "systemctl start --user monitor-input-switcher";
                iconOn = toString ./monitor-switcher-enabled.svg;

                offScriptEnabled = true;
                offScript = "systemctl stop --user monitor-input-switcher";
                iconOff = toString ./monitor-switcher-disabled.svg;

                statusScriptEnabled = true;
                statusScript = "systemctl status --user monitor-input-switcher | grep 'Active: active'";
                runStatusOnStart = true;
                interval = 300; # in seconds
                updateInterval = 5;
                updateIntervalUnit = 1; # 0 s, 1 m, 2 h
              };
            })

            {
              systemTray = {
                icons = {
                  spacing = "small";
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
          ];
        };

        launcherPanel = {
          location = "top";
          floating = true;
          hiding = "dodgewindows";
          alignment = "center";
          opacity = "translucent";
          screen = 0;
          height = 56;
          lengthMode = "fit";
          widgets = [
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
          ];
        };
      in
      [ topBar ] ++ (flip genList 2 (i: launcherPanel // { screen = i; }));
  };
}
