{ pkgs, ... }:
let
  xrpkgs = pkgs.nixpkgs-xr;
in
{
  environment.systemPackages = with xrpkgs; [
    wayvr
  ];

  services.wivrn = {
    enable = true;
    package = xrpkgs.wivrn;
    defaultRuntime = true;
    openFirewall = true;
  };
}
