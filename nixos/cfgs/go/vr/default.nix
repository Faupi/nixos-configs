{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wlx-overlay-s # First time setup to run as `steam-run wlx-overlay-s`
    # Used for the SteamVR util | TODO: Substitute in?
    jq
    moreutils # sponge
  ];
  # TODO: Put scripts into home directory or somewhere idk Steam and ALVR cannot access them in etc for some ungodly reason

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

  # Patch to resolve issues with async reprojection
  # https://wiki.nixos.org/wiki/VR#SteamVR
  boot.kernelPatches = [
    {
      name = "amdgpu-ignore-ctx-privileges";
      patch = pkgs.fetchpatch {
        name = "cap_sys_nice_begone.patch";
        url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
        hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
      };
    }
  ];
}
