{ pkgs, ... }: {
  # Make sure to keep graphics drivers fully up to date. Good features yo.
  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.unstable)
        mesa
        libdrm
        libva
        libvdpau-va-gl
        libva-vdpau-driver
        vulkan-loader
        vulkan-validation-layers

        amdgpu_top
        libva-utils
        vulkan-tools;

      pkgsi686Linux = {
        inherit (prev.unstable.pkgsi686Linux)
          mesa
          libdrm
          libva
          libvdpau-va-gl
          libva-vdpau-driver
          vulkan-loader
          vulkan-validation-layers;
      };
    })
  ];

  environment = {
    sessionVariables = {
      PROTON_FSR4_UPGRADE = 1; # FSR 3.1+ gets upgraded to FSR4 
      ENABLE_LAYER_MESA_ANTI_LAG = 1; # Improves latency (mesa 25.3+)

      # Remove these if the system is alright without them
      LIBVA_DRIVER_NAME = "radeonsi";
      LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
    };
    systemPackages = with pkgs; [
      amdgpu_top
      libva-utils
      vulkan-tools
    ];
  };

  boot = {
    kernelModules = [
      "amdgpu"
    ];
    # kernelParams = [
    #   "amdgpu.virtual_display=0000:03:00.0,1" # Expose one virtual display
    # ];
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
      package = pkgs.mesa;
      package32 = pkgs.pkgsi686Linux.mesa;
    };
  };
}
