{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wlx-overlay-s # First time setup to run as `steam-run wlx-overlay-s`
  ];

  # SteamVR | NOTE: Needs to be configured manually in Steam `steamvr-wrapper %command%`
  programs.steam.extraPackages = [
    (pkgs.writeShellApplication {
      name = "steamvr-wrapper";
      runtimeInputs = with pkgs; [
        jq
        moreutils
      ];
      text = builtins.readFile ./steamvr-wrapper.sh;
    })
  ];

  # ALVR
  programs.alvr = {
    enable = true;
    openFirewall = true;
    package = pkgs.alvr;
  };

  # Patch to resolve issues with async reprojection
  # https://wiki.nixos.org/wiki/VR#SteamVR
  # boot.kernelPatches = [
  #   {
  #     name = "amdgpu-ignore-ctx-privileges";
  #     patch = pkgs.fetchpatch {
  #       name = "cap_sys_nice_begone.patch";
  #       url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
  #       hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
  #     };
  #   }
  # ];
}
