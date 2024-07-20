{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wlx-overlay-s # First time setup to run as `steam-run wlx-overlay-s`
    # For ALVR util | TODO: Substitute in
    jq
    moreutils # sponge
  ];

  # SteamVR | NOTE: Needs to be configured manually in Steam `/etc/steamvr-wrapper.sh %command%`
  environment.etc."SteamVR Wrapper" = {
    source = ./steamvr-wrapper.sh;
    target = "steamvr-wrapper.sh";
    mode = "0755";
  };

  # ALVR
  programs.alvr = {
    enable = true;
    openFirewall = true;
    package = pkgs.alvr;
  };

  environment.etc."ALVR Session Handler" = {
    # TODO: Set up auto link to ALVR config?
    source = ./alvr-session.sh;
    target = "alvr-session.sh";
    mode = "0755";
  };
}
