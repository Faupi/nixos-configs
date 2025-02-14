{ config, ... }: {
  imports = [
    ./video-stream.nix
    ./plugin-overlay.nix
  ];

  environment.shellAliases = {
    octoconf = "nano ${config.services.octoprint.stateDir}/config.yaml";
  };

  services.octoprint = {
    enable = true;
    user = "octoprint";
    stateDir = "/var/lib/octoprint";

    port = 5000;
    openFirewall = true;

    plugins = plugins:
      with plugins; [
        displaylayerprogress
        dashboard
        bedlevelvisualizer
        printtimegenius
        cura-thumbnails
        slicer-thumbnails
        heater-timeout
        pretty-gcode
        exclude-region
        ui-customizer
        temp-control
      ];

    extraConfig = {
      plugins = rec {
        _disabled = [ "softwareupdate" ];
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
          state_panel_thumbnail_scale_value = "100";
        };
        prusaslicerthumbnails = UltimakerFormatPackage; # Same settings

        uicustomizer =
          # Use the export as a base 
          # (OctoPrint > Settings > Plugins > UI Customizer > Advanced > Export settings)
          builtins.fromJSON (builtins.readFile ./ui-customizer-export.json)
          # Apply overrides
          // {
            themeLocal = true;
            theme = "discoranged";
            customCSS = builtins.readFile ./customcss.css;
          };

        consolidate_temp_control = {
          layout = "vertical";
          tab_order = [
            {
              name = "Temperature";
              selector = "#temp, #tab_plugin_plotlytempgraph";
            }
            {
              name = "Control";
              selector = "#control";
            }
          ];
        };
      };
    };
  };
}
