{ pkgs, ... }:
{
  programs.alvr = {
    enable = true;
    openFirewall = true;
    package = pkgs.alvr;
  };

  environment.etc."ALVR Session Handler" = {
    # TODO: Set up auto link to ALVR config?
    source = ./alvr-session.sh;
    target = "alvr-session.sh";
    mode = "0711";
  };

  environment.systemPackages = with pkgs; [
    wlx-overlay-s # First time setup to run as `steam-run wlx-overlay-s`
    jq # For ALVR util | TODO: Substitute
  ];
}
