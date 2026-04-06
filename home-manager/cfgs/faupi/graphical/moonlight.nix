{ pkgs, lib, ... }:
let
  package = pkgs.moonlight-qt;

  moonlight-lynx-mic = rec {
    cmd = pkgs.writeShellApplication {
      name = "moonlight-lynx-mic";
      runtimeInputs = with pkgs; [
        package
        pipewire
      ];
      text = /*sh*/''
        # Kill backgrounded ROC and Loopback processes on exit
        trap 'kill $(jobs -p)' EXIT SIGINT SIGTERM

        # Network pipe
        pw-cli -m load-module libpipewire-module-roc-sink '{
          fec.code = "rs8m",
          remote.ip = "192.168.0.100",
          remote.source.port = 10001,
          remote.repair.port = 10002,
          remote.control.port = 10003,
          sink.props = {
            node.name = "moonlight-mic-sender",
            media.class = "Audio/Sink"
          }
        }' &

        # Give PipeWire a heartbeat to register the sink
        sleep 0.2

        # Connect default mic to pipe
        pw-cli -m load-module libpipewire-module-loopback '{
          capture.props = {
            node.target = "@DEFAULT_SOURCE@",
            media.class = "Stream/Input/Audio",
            node.description = "Moonlight Mic Bridge"
          },
          playback.props = {
            node.target = "moonlight-mic-sender",
            media.class = "Stream/Output/Audio"
          }
        }' &

        ${lib.getExe package} stream lynx 'Desktop (Mic)' --quit-after
      '';
    };

    desktopfile = pkgs.makeDesktopItem {
      name = "com.moonlight_stream.Moonlight-Lynx_MIC";
      desktopName = "Moonlight (Lynx) - MIC";
      comment = "Stream games from your NVIDIA GameStream-enabled PC";
      terminal = false;
      icon = "moonlight";
      type = "Application";
      categories = [ "Qt" "Game" ];
      keywords = [ "nvidia" "gamestream" "stream" ];
      exec = lib.getExe cmd;
    };
  };
in
{
  home.packages = with pkgs; [
    moonlight-qt
  ]
  ++ (with moonlight-lynx-mic; [
    cmd
    desktopfile
  ]);
}
