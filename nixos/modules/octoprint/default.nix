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
        uicustomizer = {
          themeLocal = true;
          theme = "discoranged";
        };
      };
    };
  };
}
