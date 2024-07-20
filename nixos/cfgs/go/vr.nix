{ pkgs, ... }:
{
  programs.alvr = {
    enable = true;
    openFirewall = true;
    package = pkgs.alvr;
  };

  environment.systemPackages = with pkgs; [
    wlx-overlay-s
  ];
}
