{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wlx-overlay-s # First time setup to run as `steam-run wlx-overlay-s`
    xrizer
  ];

  services.wivrn = {
    enable = true;
    package = pkgs.wivrn;
    defaultRuntime = true;
    openFirewall = true;
  };
}
