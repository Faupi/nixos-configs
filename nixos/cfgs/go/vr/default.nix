{ pkgs, ... }:
let
  xrpkgs = pkgs.nixpkgs-xr;
in
{
  environment.systemPackages = with xrpkgs; [
    wlx-overlay-s # First time setup to run as `steam-run wlx-overlay-s`
  ];

  services.wivrn = {
    enable = true;
    package = xrpkgs.wivrn;
    defaultRuntime = true;
    openFirewall = true;
  };
}
