{ config, pkgs, lib, ... }: {
  # For plugin packages
  imports = [
    ./overlays.nix
  ];

  environment.shellAliases = {
    octoconf = "nano ${config.services.octoprint.stateDir}/config.yaml";
  };

  services.octoprint = {
    enable = true;
    port = 5000;
    openFirewall = true;

    plugins = plugins: with plugins; [ 
      displaylayerprogress
      octoprint-dashboard
      touchui
      bedlevelvisualizer
      printtimegenius
      themeify
      widescreen
      cura-thumbnails
      heater-timeout
      pretty-gcode
      custom-css
    ];
  
    extraConfig = {
      plugins = {
        _disabled = [
          "softwareupdate"
        ];

        themeify = {
          theme = "discoranged";
          enableCustomization = true;
          tabs = {
            enableIcons = true;
            icons = [
              {
                domId = "#temp_link";
                enabled = true;
                faIcon = "fa fa-thermometer-half";
              }
              {
                domId = "#control_link";
                enabled = true;
                faIcon = "fa fa-gamepad";
              }
              {
                domId = "#gcode_link";
                enabled = true;
                faIcon = "fa fa-object-ungroup";
              }
              {
                domId = "#term_link";
                enabled = true;
                faIcon = "fa fa-terminal";
              }
              {
                domId = "#tab_plugin_dashboard_link";
                enabled = true;
                faIcon = "fa fa-tachometer";
              }
              {
                domId = "#tab_plugin_bedlevelvisualizer_link";
                enabled = true;
                faIcon = "fa fa-balance-scale";
              }
              {
                domId = "#timelapse_link";
                enabled = true;
                faIcon = "fa fa-clock-o";
              }
              {
                domId = "#tab_plugin_prettygcode_link";
                enabled = true;
                faIcon = "fa fa-cube";
              }
            ];
          };
          customRules = [];
        };
        customcss.css = (builtins.readFile ./customcss.css);
        widescreen = {
          right_sidebar_items = [
            "connection"
            "state"
          ];
        };
        DisplayLayerProgress = {
          showAllPrinterMessages = false;
          showOnFileListView = false;
        };
        UltimakerFormatPackage = {
          inline_thumbnail = true;
          inline_thumbnail_align_value = "right";
          inline_thumbnail_position_left = true;
          inline_thumbnail_scale_value = "15";
          scale_inline_thumbnail = true;
          state_panel_thumbnail_scale_value = "50";
        };
        touchui = {
          # Note: With customization it tries to write into its package, which throws errors. 
          #       Fixing this is not possible without rewriting the whole thing.
          closeDialogsOutside = true;
          useCustomization = false;
        };
      };
    };
  };
}