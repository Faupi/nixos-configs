{ cfg, ... }:
{
  services.pipewire = {
    enable = true;
    pulse.enable = true;

    extraConfig.pipewire."99-roc-receiver" = {
      "context.modules" = [
        {
          name = "libpipewire-module-roc-source";
          args = {
            "fec.code" = "disable";
            "local.ip" = "0.0.0.0"; # Listen on all interfaces
            "local.source.port" = 10001;
            "local.repair.port" = 10002;
            "local.control.port" = 10003;
            "source.name" = "ROC Network Source";
            "source.props" = {
              "node.name" = cfg.defaultAudioSource;
              "node.description" = "Network Mic Receiver";
              "media.class" = "Audio/Source";
            };
            "audio.position" = [ "FL" "FR" ];
          };
        }
      ];
    };
  };

  networking.firewall.allowedUDPPorts = [
    10001
    10002
    10003
  ];
}
