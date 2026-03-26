{ pkgs, ... }:
let
  # Make sure to keep graphics drivers fully up to date. Good features yo.
  gpuPkgs = pkgs.unstable;
in
{
  environment = {
    sessionVariables = {
      PROTON_FSR4_UPGRADE = 1; # FSR 3.1+ gets upgraded to FSR4 
      ENABLE_LAYER_MESA_ANTI_LAG = 1; # Improves latency (mesa 25.3+)

      # Remove these if the system is alright without them
      LIBVA_DRIVER_NAME = "radeonsi";
      LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
    };
    systemPackages = with gpuPkgs; [
      amdgpu_top
      libva-utils
      vulkan-tools
    ];
  };

  boot = {
    kernelModules = [
      "kvm-amd"
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
      package = gpuPkgs.mesa.drivers;
      package32 = gpuPkgs.pkgsi686Linux.mesa.drivers;
      extraPackages = with gpuPkgs; [
        libva
        libvdpau-va-gl
        vulkan-loader
      ];
      extraPackages32 = with gpuPkgs.pkgsi686Linux; [
        libva
        libvdpau-va-gl
        vulkan-loader
      ];
    };
  };
}
