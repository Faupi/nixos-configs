{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkIf types;
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
      defaultRuntime = true;
      openFirewall = true;
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
              exec = lib.getExe wivrn-connection-manager;
              mgr-cfg = (pkgs.formats.json { }).generate "config.json" {
                on_startup = [
                  {
                    exec = "${lib.getExe wayvr} --openxr --show";
                    args = [ ];
                    env = {
                      PATH = "/run/current-system/sw/bin";
                    };
                  }
                ];
                on_connect = [
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
                on_disconnect = [ ]
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
  };
}
