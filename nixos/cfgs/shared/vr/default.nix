{ pkgs, lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.flake-configs.vr;

  xrpkgs = pkgs.nixpkgs-xr;

  inherit (xrpkgs) wayvr xrizer;
  xrizerlib = "${xrizer}/lib/xrizer";
  wivrn = pkgs.unstable.wivrn; # Use unstable to stay in line with the Quest client version
in
{
  options.flake-configs.vr = {
    enable = mkEnableOption "VR configuration";
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
          # TODO: Maybe use an auto-setup script https://github.com/Kirottu/nixos/blob/8de3a5503fa31cd73a545a15e1a2f33a8ecc9735/modules/gaming/vr/default.nix#L214-L294
          application = (pkgs.writeShellApplication {
            name = "wivrn-autostart";
            text = ''
              ${lib.getExe wayvr} --openxr --show
            '';
          });
          openvr-compat-path = xrizerlib;
          bitrate = 100 * 1000 * 1000; #Mbit
          debug-gui = false;
          hid-forwarding = false;
          scale = 0.4;
          use-steamvr-lh = false;
        };
      };
    };
  };
}
