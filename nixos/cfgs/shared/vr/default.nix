{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkIf types getExe;
  cfg = config.flake-configs.vr;

  xrpkgs = pkgs.nixpkgs-xr;

  inherit (xrpkgs) wayvr xrizer;
  xrizerlib = "${xrizer}/lib/xrizer";
  wivrn = pkgs.unstable.wivrn; # Use unstable to stay in line with the Quest client version
  wivrn-connection-manager = pkgs.wivrn-connection-manager;
in
{
  options.flake-configs.vr = {
    enable = mkEnableOption "VR configuration";
    autoStart = mkEnableOption "Auto-start";
    defaultSink = mkOption { type = types.nullOr types.str; default = null; };
    defaultSource = mkOption { type = types.nullOr types.str; default = null; };
  };

  config = mkIf cfg.enable {
    environment = {
      sessionVariables = {
        VR_OVERRIDE = xrizerlib;
      };
      systemPackages = [
        wayvr
        xrizer
      ];
    };

    services.wivrn = {
      enable = true;
      package = wivrn;
      autoStart = cfg.autoStart;
      defaultRuntime = mkIf (lib.versionAtLeast config.system.stateVersion "26.06") true;
      openFirewall = true;
      highPriority = true;
      steam.importOXRRuntimes = true;
      config = {
        enable = true;
        json = {
          openvr-compat-path = xrizerlib;
          bitrate = 100 * 1000 * 1000; #Mbit
          debug-gui = false;
          hid-forwarding = false;
          scale = 0.4;
          use-steamvr-lh = false;

          # https://github.com/Kirottu/nixos/blob/8de3a5503fa31cd73a545a15e1a2f33a8ecc9735/modules/gaming/vr/default.nix#L214-L294
          application =
            let
              exec = getExe wivrn-connection-manager;
              sleepInhibitionPidPath = "/tmp/wivrn-inhibit-sleep.pid";
              mgr-cfg = (pkgs.formats.json { }).generate "config.json" {
                on_startup = [
                  {
                    exec = "${getExe wayvr}";
                    args = [
                      "--openxr"
                      "--show"
                      "--replace" # Make sure it can unstick itself with a new session
                    ];
                    env = {
                      # Allow it to start applications
                      PATH = "/run/current-system/sw/bin:$PATH";
                    };
                  }
                ];
                on_connect = [
                  {
                    exec = getExe (pkgs.writeShellApplication {
                      name = "wivrn-sleep-lock";
                      runtimeEnv = { tmp_pid = sleepInhibitionPidPath; };
                      runtimeInputs = with pkgs; [
                        systemd
                      ];
                      text = /*sh*/''
                         systemd-inhibit \
                          --what=idle:sleep \
                          --who="WiVRn" \
                          --why="Active game stream" \
                          --mode=block \
                          sleep infinity &
                        echo $! > "$tmp_pid"
                      '';
                    });
                  }
                  {
                    exec = "${pkgs.pulseaudio}/bin/pactl";
                    args = [
                      "set-default-sink"
                      "wivrn.sink"
                    ];
                    env = { };
                  }
                  {
                    exec = "${pkgs.pulseaudio}/bin/pactl";
                    args = [
                      "set-default-source"
                      "wivrn.source"
                    ];
                    env = { };
                  }
                ];
                on_disconnect = [
                  {
                    exec = getExe (pkgs.writeShellApplication {
                      name = "wivrn-sleep-unlock";
                      runtimeEnv = { tmp_pid = sleepInhibitionPidPath; };
                      text = /*sh*/''
                        if [ -f "$tmp_pid" ]; then
                          kill "$(cat "$tmp_pid")" 2>/dev/null || true
                          rm "$tmp_pid"
                        fi
                      '';
                    });
                  }
                ]
                ++ (lib.lists.optional (cfg.defaultSink != null)
                  {
                    exec = "${pkgs.pulseaudio}/bin/pactl";
                    args = [
                      "set-default-sink"
                      cfg.defaultSink
                    ];
                    env = { };
                  })
                ++ (lib.lists.optional (cfg.defaultSource != null)
                  {
                    exec = "${pkgs.pulseaudio}/bin/pactl";
                    args = [
                      "set-default-source"
                      cfg.defaultSource
                    ];
                    env = { };
                  });
                kill_timeout = 300;
              };
            in
            (pkgs.writeShellApplication {
              name = "wivrn-autostart";
              text = ''
                ${exec} -c ${mgr-cfg}
              '';
            });
        };
      };
    };

    # Add wayvr to path otherwise it fails to launch it (despite seeing it)
    systemd.user.services.wivrn.path = [ wayvr ];
  };
}
