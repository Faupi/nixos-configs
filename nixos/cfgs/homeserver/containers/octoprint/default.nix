{ ... }:
let
  camDev = "/dev/video0";
  printerDev = "/dev/ttyUSB0";

  octoPort = 5000;
  camPort = 5050;

  tcp = port: {
    hostPort = port;
    protocol = "tcp";
  };
in
{
  networking.firewall = {
    allowedTCPPorts = [ octoPort camPort ];
  };

  containers.octoprint = {
    autoStart = true;
    forwardPorts = [ (tcp octoPort) (tcp camPort) ];
    allowedDevices = [
      {
        node = camDev;
        modifier = "rwm";
      }
      {
        node = printerDev;
        modifier = "rwm";
      }
    ];
    bindMounts = {
      "/dev/host" = {
        hostPath = "/dev";
        isReadOnly = false;
      };
    };

    config = {
      system.stateVersion = "25.05";

      imports = [
        ./plugin-overlay.nix
      ];

      networking.firewall = {
        allowedTCPPorts = [ octoPort camPort ];
      };

      services = {
        mjpg-streamer = {
          enable = true;
          inputPlugin = "input_uvc.so --device ${camDev} --resolution 1280x720 --fps 30 -wb 4000 -bk 1 -ex 1000 -gain 255 -cagc auto -sh 100";
          outputPlugin = "output_http.so -w @www@ -n -p ${toString camPort}";
        };

        octoprint = {
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
      };
    };
  };
}
