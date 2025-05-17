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
                matches = [{ "node.name" = nodeName; "port.monitor" = "!true"; }];
              };
            in
            {
              "custom-device-names" = {
                "monitor.alsa.rules" = [
                  (setName "Trust GXT 232" "alsa_input.usb-145f_Trust_GXT_232_Microphone-00.mono-fallback")

                  (setName "Analog Microphone" "alsa_input.usb-GeneralPlus_USB_Audio_Device-00.pro-input-0")
                  (setName "Analog Headphones" "alsa_output.usb-GeneralPlus_USB_Audio_Device-00.pro-output-0")

                  (setName "Legion Microphone" "alsa_input.pci-0000_c2_00.6.analog-stereo")
                  (setName "Legion Speakers" "alsa_output.pci-0000_c2_00.6.analog-stereo")

                  (setName "HDMI" "alsa_output.pci-0000_c2_00.1.hdmi-stereo")
                ];
              };
            };
        };
      };
    };
  };
}
