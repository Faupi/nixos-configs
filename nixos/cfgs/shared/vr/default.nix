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
          application = [
            wayvr # NOTE: Needs to be the package directly
          ];
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
