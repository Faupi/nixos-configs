{ config, pkgs, lib, cfg, sharedOptions, ... }:
let
  inherit (builtins) toJSON;
  inherit (lib) mkOption mkEnableOption attrsets types mkIf flip genList recursiveUpdate;
  hasMonitorSwitcher = attrsets.hasAttrByPath [ "systemd" "user" "services" "monitor-input-switcher" ] config;
in
{
  # Very much optional helper option to override the launcher icons
  options.flake-configs.plasma = {
    launcherIcon = mkOption {
      type = with types; nullOr str;
      default = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
    };
    flowmodoro.enable = mkEnableOption "Flowmodoro timer";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # kde.widgets.plasma-drawer
      kara
    ]
    ++ (lib.lists.optional hasMonitorSwitcher kde.widgets.plasmoid-button)
    ++ (lib.lists.optional cfg.flowmodoro.enable (kde.widgets.fokus.override { addFlowIcon = true; }));

    programs.plasma.panels =
      let
        systemMonitorDefaultPopupSize = {
          popupHeight = 10; # As small as possible - gets clamped
          popupWidth = 300; # Comfy enough to fit text
        };

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

            # {
            #   plasmaPanelColorizer = {
            #     general = {
            #       enable = true;
            #       hideWidget = true;
            #     };
            #     panelBackground = {
            #       originalBackground = {
            #         hide = false;
            #         opacity = 0;
            #         # WHERE SHADOW KURWA https://github.com/nix-community/plasma-manager/blob/205dcfd4a30d4a5d1b4f28defee69daa7c7252cd/modules/widgets/plasma-panel-colorizer.nix#L515-L533
            #       };
            #     };
            #   };
            # }


            {
              panelSpacer = {
                expanding = true;
              };
            }

            {
              systemMonitor = rec {
                displayStyle = "org.kde.ksysguard.horizontalbars";
                title = "System Resources - Processing";
                showTitle = true;
                showLegend = true;
                settings = recursiveUpdate
                  systemMonitorDefaultPopupSize
                  {
                    "org.kde.ksysguard.horizontalbars/General" = {
                      rangeAuto = false;
                      rangeFrom = 0;
                      rangeTo = 100;
                    };
                    "Sensors" = {
                      # REVIEW: Fix for plasma-manager's escaping breaking with recent Plasma
                      highPrioritySensorIds = toJSON (map (s: s.name) sensors);
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
          ]
          ++ (lib.optionals cfg.flowmodoro.enable [
            {
              name = "com.dv.fokus";
              config = {
                General = {
                  clock_fontfamily = "Outfit";
                  show_time_in_compact_mode = true;
                  do_not_disturb_enabled = false;
                  show_fullscreen_break = false;
                  fullscreen_buttons_postpone = false;
                  flowmodoro_mode_enabled = true;

                  flow_divisor = 3;

                  # NOTE: Sound paths need to be linked directly
                  timer_start_notification_enabled = true;
                  timer_start_sfx_enabled = true;
                  timer_start_sfx_filepath = "${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/dialog-information.oga";

                  timer_end_notification_enabled = true;
                  timer_stop_sfx_enabled = true;
                  timer_stop_sfx_filepath = "${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/dialog-question.oga";

                  timer_tick_sfx_enabled = false; # NOTE: Tick SFX doesn't apply to flowmodoro
                  timer_tick_sfx_filepath = "${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/dialog-warning.oga";
                };
              };
            }

            # Fill missing padding on the right
            {
              panelSpacer = {
                expanding = false;
                length = 3;
              };
            }
          ])
          ++
          [
            {
              systemMonitor = rec {
                displayStyle = "org.kde.ksysguard.horizontalbars";
                title = "System Resources - Memory";
                showTitle = true;
                showLegend = true;
                settings = recursiveUpdate
                  systemMonitorDefaultPopupSize
                  {
                    "org.kde.ksysguard.horizontalbars/General" = {
                      rangeAuto = false;
                      rangeFrom = 0;
                      rangeTo = 100;
                    };
                    "Sensors" = {
                      # REVIEW: Fix for plasma-manager's escaping breaking with recent Plasma
                      highPrioritySensorIds = toJSON (map (s: s.name) sensors);
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

            {
              panelSpacer = {
                expanding = true;
              };
            }

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
                    "org.kde.plasma.keyboardlayout"
                    "org.kde.plasma.volume"
                  ];
                  hidden = [
                    "Discover Notifier_org.kde.DiscoverNotifier"
                    "Easy Effects"
                    "KDE Daemon"
                    "org.kde.kalendar.contact"
                    "org.kde.kdeconnect"
                    "org.kde.kscreen"
                    "org.kde.plasma.brightness"
                    "org.kde.plasma.clipboard"
                    "org.kde.plasma.devicenotifier"
                    "The KDE Crash Handler"
                    "touchpad"
                    "Wallet Manager"
                  ];
                };
              };
            }
          ];
        };

        launcherPanel = {
          location = "top";
          floating = true;
          hiding = "autohide"; # Stays hidden unless opened - prettier and fixes Yakuake
          alignment = "center";
          opacity = "translucent";
          screen = 0;
          height = 56;
          lengthMode = "fit";
          # Floating applets only (Basically stays perfectly aligned to the top when open)
          extraSettings = /*js*/''
            panel.floatingApplets = true;
          '';
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
      [ topBar ] ++ (flip genList 1 (i: launcherPanel // { screen = i; })); # TODO: genList X by number of displays
  };
}
