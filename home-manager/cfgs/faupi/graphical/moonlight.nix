{ pkgs, lib, ... }:
let
  package = pkgs.moonlight-qt;

  micLoopbackSource = "moonlight_mic_bridge.source";
  micLoopbackSink = "moonlight_mic_bridge.sink";
  micSender = "moonlight_mic_sender";
  moonlight-lynx-mic = rec {
    cmd = pkgs.writeShellApplication {
      name = "moonlight-lynx-mic";
      runtimeInputs = with pkgs; [
        package
        pipewire
      ];
      runtimeEnv = {
        inherit micLoopbackSource micLoopbackSink micSender;
      };
      text = /*sh*/''
        # Kill backgrounded ROC and Loopback processes on exit
        trap 'kill $(jobs -p)' EXIT SIGINT SIGTERM

        get_host_address() {
          local hostname="$1"
          local moonlight_conf="$HOME/.config/Moonlight Game Streaming Project/Moonlight.conf"

          local ip
          ip=$(awk -F'[=\\\\]' -v target="$hostname" '
            /hostname=/     {idx=$1; name=$NF}
            /localaddress=/ {if ($1==idx && name==target) {print $NF; exit}}
          ' "$moonlight_conf")

          [ -n "$ip" ] || {
            echo "Host address not found: $hostname - make sure the host is in Moonlight" >&2
            return 1
          }

          printf '%s\n' "$ip"
        }

        # Network pipe
        IP=$(get_host_address "lynx") || exit 1
        pw-cli -m load-module libpipewire-module-roc-sink "{
          fec.code = \"rs8m\",
          remote.ip = \"$IP\",
          remote.source.port = 10001,
          remote.repair.port = 10002,
          remote.control.port = 10003,
          sink.props = {
            node.name = \"$micSender\",
            media.class = \"Audio/Sink\"
          }
        }" &

        # Give PipeWire a heartbeat to register the sink
        sleep 0.2

        # Connect default mic to pipe
        # NOTE: Using `media.role = "Notification"` to stop EasyEffects from grabbing it, as blocklists do not work currently.
        pw-cli -m load-module libpipewire-module-loopback "{
          capture.props = {
            node.name = \"$micLoopbackSink\",
            node.target = \"@DEFAULT_SOURCE@\",
            node.description = \"Moonlight Mic Bridge IN\",
            stream.capture.source = true
          },
          playback.props = {
            node.name = \"$micLoopbackSource\",
            node.target = \"$micSender\",
            node.description = \"Moonlight Mic Bridge OUT\",
            media.role = \"Notification\",
            node.autoconnect = true
          }
        }" &

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
