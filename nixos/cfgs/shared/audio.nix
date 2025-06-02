{ config, lib, ... }:
let
  cfg = config.flake-configs.audio;
in
{
  options.flake-configs.audio = {
    enable = lib.mkEnableOption "Enable audio handling";
    user = lib.mkOption {
      type = lib.types.str;
      example = "faupi";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user}.extraGroups = [ "pipewire" ];

    security.rtkit.enable = true;

    services = {
      pulseaudio.enable = lib.mkForce false;

      pipewire = {
        enable = true;

        pulse.enable = true;

        alsa = {
          enable = true;
          support32Bit = true;
        };

        wireplumber = {
          enable = true;
          extraConfig =
            let
              # Set name the same as Plasma settings' "Sound > Rename Devices" do
              setName = customName: matches: {
                matches = [ ({ "port.monitor" = "!true"; } // matches) ];

                actions = {
                  update-props = lib.attrsets.genAttrs [
                    "alsa.card_name"
                    "alsa.long_card_name"
                    "device.description"
                    "device.name"
                    "node.description"
                    "node.nick"
                  ]
                    (name: customName);
                };
              };
            in
            {
              "custom-device-names" = {
                "monitor.alsa.rules" = [
                  # External shared peripherals
                  # NOTE: Try to keep matching rules tied to device rather than profiles
                  (setName "Trust GXT 232" {
                    "alsa.components" = "USB145f:0254";
                    "port.group" = "capture";
                  })
                  (setName "C270 Webcam" {
                    "alsa.components" = "USB046d:0825";
                    "port.group" = "capture";
                  })

                  (setName "USB Hub Headphones Microphone" {
                    "alsa.components" = "USB1b3f:2008";
                    "port.group" = "capture";
                  })
                  (setName "USB Hub Headphones" {
                    "alsa.components" = "USB1b3f:2008";
                    "port.group" = "playback";
                  })

                  # REVIEW Hardware-specific configurations - maybe move under system configs?
                  # masp
                  (setName "On-board Microphone" {
                    "node.name" = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source";
                  })
                  (setName "On-board HDMI 1" {
                    "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI1__sink";
                  })
                  (setName "On-board HDMI 2" {
                    "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI2__sink";
                  })
                  (setName "On-board HDMI 3" {
                    "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI3__sink";
                  })
                  (setName "On-board Headphones Microphone" {
                    "node.name" = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic2__source";
                  })
                  (setName "On-board Headphones" {
                    "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Headphones__sink";
                  })

                  # go
                  (setName "On-board HDMI" {
                    "node.name" = "alsa_output.pci-0000_c2_00.1.hdmi-stereo";
                  })
                  (setName "On-board Microphone" {
                    "node.name" = "alsa_input.pci-0000_c2_00.6.analog-stereo";
                  })
                  (setName "On-board Speakers" {
                    "node.name" = "alsa_output.pci-0000_c2_00.6.analog-stereo";
                  })
                ];
              };
            };
        };
      };
    };
  };
}
