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
              setName = customName: nodeName: {
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
                # REVIEW: Look into more general rules for a device as a whole to avoid having to match specific profiles like `pro-input-0` - use e.g. `device.bus-id`, though this isn't super applicable to multi-node devices.
                matches = [{ "node.name" = nodeName; "port.monitor" = "!true"; }];
              };
            in
            {
              "custom-device-names" = {
                "monitor.alsa.rules" = [
                  (setName "Trust GXT 232" "alsa_input.usb-145f_Trust_GXT_232_Microphone-00.mono-fallback")
                  (setName "C270 Webcam" "alsa_input.usb-046d_C270_HD_WEBCAM_200901010001-02.mono-fallback")

                  (setName "USB Hub Headphones Microphone" "alsa_input.usb-GeneralPlus_USB_Audio_Device-00.pro-input-0")
                  (setName "USB Hub Headphones Microphone" "alsa_input.usb-GeneralPlus_USB_Audio_Device-00.mono-fallback")
                  (setName "USB Hub Headphones" "alsa_output.usb-GeneralPlus_USB_Audio_Device-00.pro-output-0")
                  (setName "USB Hub Headphones" "alsa_output.usb-GeneralPlus_USB_Audio_Device-00.analog-stereo")

                  (setName "HDMI" "alsa_output.pci-0000_c2_00.1.hdmi-stereo")

                  # REVIEW Hardware-specific configurations - maybe move under system configs?
                  # masp
                  (setName "On-board Microphone" "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source")
                  (setName "On-board HDMI 1" "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI1__sink")
                  (setName "On-board HDMI 2" "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI2__sink")
                  (setName "On-board HDMI 3" "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI3__sink")
                  (setName "On-board Headphones Microphone" "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic2__source")
                  (setName "On-board Headphones" "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Headphones__sink")

                  # go
                  (setName "On-board Microphone" "alsa_input.pci-0000_c2_00.6.analog-stereo")
                  (setName "On-board Speakers" "alsa_output.pci-0000_c2_00.6.analog-stereo")
                ];
              };
            };
        };
      };
    };
  };
}
