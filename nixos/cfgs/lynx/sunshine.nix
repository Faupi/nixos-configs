{ cfg, lib, pkgs, ... }:
let
  inherit (lib) getExe;
in
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = false;
    settings = {
      system_tray = false; # No tray
      controller = "enabled";
      back_button_timeout = 2000;
      keyboard = "enabled";
      mouse = "enabled";
      native_pen_touch = "enabled";
      encoder = "hardware";

      stream_audio = true;
      output_name = cfg.defaultDisplay;

      virtual_sink = "${cfg.defaultAudioSink}.monitor";

      lan_encryption_mode = 2; # "encryption is mandatory and unencrypted connections are rejected"
      origin_web_ui_allowed = "lan";
      upnp = "disabled";

      global_prep_cmd = builtins.toJSON [
        # Set display properties to match client
        {
          do = getExe (pkgs.writeShellApplication {
            name = "update-display";
            runtimeEnv = {
              inherit (cfg) defaultDisplay;
            };
            runtimeInputs = with pkgs; [
              wlr-randr
            ];
            text = /*sh*/''
              wlr-randr \
                --output "$defaultDisplay" \
                --custom-mode "''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}Hz" \
                --scale 1
            '';
          });
        }

        # Inhibit sleep
        (
          let
            tmp_pid = "/tmp/sunshine-inhibit-sleep.pid";
          in
          {
            do = getExe (pkgs.writeShellApplication {
              name = "sunshine-sleep-lock";
              runtimeEnv = { inherit tmp_pid; };
              runtimeInputs = with pkgs; [
                systemd
              ];
              text = /*sh*/''
                 systemd-inhibit \
                  --what=idle:sleep \
                  --who="Sunshine" \
                  --why="Active game stream" \
                  --mode=block \
                  sleep infinity &
                echo $! > "$tmp_pid"
              '';
            });

            undo = getExe (pkgs.writeShellApplication {
              name = "sunshine-sleep-unlock";
              runtimeEnv = { inherit tmp_pid; };
              text = /*sh*/''
                if [ -f "$tmp_pid" ]; then
                  kill "$(cat \"$tmp_pid\")" 2>/dev/null || true
                  rm "$tmp_pid"
                fi
              '';
            });
          }
        )
      ];
    };

    applications = {
      apps = [
        {
          name = "Desktop";
        }
        {
          name = "Desktop (Mic)";
          prep-cmd = [
            {
              do = getExe (pkgs.writeShellApplication {
                name = "sunshine-microphone-setup";
                runtimeEnv = {
                  inherit (cfg) defaultAudioSource;
                };
                runtimeInputs = with pkgs; [
                  pulseaudio
                ];
                text = /*sh*/''
                  pactl load-module module-roc-source \
                    fec_code=rs8m \
                    local_ip=0.0.0.0 \
                    local_source_port=10001 \
                    local_repair_port=10002 \
                    local_control_port=10003 \
                    source_name="$defaultAudioSource" \
                    source_properties="node.name=$defaultAudioSource" \
                    > /tmp/sunshine_roc_mod_id

                  pactl set-default-source "$defaultAudioSource"
                '';
              });
              undo = getExe (pkgs.writeShellApplication {
                name = "sunshine-microphone-teardown";
                runtimeEnv = {
                  inherit (cfg) defaultAudioSource;
                };
                runtimeInputs = with pkgs; [
                  pulseaudio
                ];
                text = /*sh*/''
                  if [ -f /tmp/sunshine_roc_mod_id ]; then
                    pactl unload-module "$(cat /tmp/sunshine_roc_mod_id)"
                    rm /tmp/sunshine_roc_mod_id
                  fi
                '';
              });
            }
          ];
        }
      ];
    };
  };

  networking = {
    firewall.interfaces.${cfg.mainInterface}.allowedUDPPorts = [
      # Sunshine microphone
      10001
      10002
      10003
    ];
  };
}
