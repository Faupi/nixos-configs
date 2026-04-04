{ ... }:
{
  # Ensure the ROC support is enabled in PipeWire
  services.pipewire = {
    enable = true;
    pulse.enable = true;

    extraConfig.pipewire."99-roc-sender" = {
      "context.modules" = [
        {
          name = "libpipewire-module-roc-sink";
          args = {
            "fec.code" = "disable";
            "remote.ip" = "10.42.0.96"; # Your Sunshine Host IP
            "remote.source.port" = 10001;
            "remote.repair.port" = 10002;
            "remote.control.port" = 10003;
            "sink.name" = "ROC Network Sink";
            "sink.props" = {
              "node.name" = "roc-network-sink";
              "node.description" = "Network Mic Sender";
              "media.class" = "Audio/Sink";
            };
            "audio.position" = [ "FL" "FR" ];
          };
        }
      ];
    };
  };
}
