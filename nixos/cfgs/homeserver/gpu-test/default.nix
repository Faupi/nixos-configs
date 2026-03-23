{ pkgs, ... }: {
  flake-configs = {
    dank-material-shell.enable = true;
    audio = {
      enable = true;
      user = "faupi";
    };
  };

  boot = {
    kernelModules = [
      "kvm-amd"
    ];
  };

  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
      ];
    };
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  environment.systemPackages = with pkgs; [
    amdgpu_top
  ];

  programs.steam = {
    enable = true;
    extest.enable = false; # X11->Wayland SteamInput mapping

    extraCompatPackages = with pkgs; [
      (proton-ge-bin.override { steamDisplayName = "GE-Proton (nix)"; })
    ];
    protontricks.enable = true;

    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
}
