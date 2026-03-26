{ pkgs, ... }: {

  environment = {
    sessionVariables = {
      PROTON_FSR4_UPGRADE = 1; # FSR 3.1+ gets upgraded to FSR4 
      ENABLE_LAYER_MESA_ANTI_LAG = 1; # Improves latency (mesa 25.3+)
    };
    systemPackages = with pkgs; [
      amdgpu_top
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

      # Make sure to keep graphics drivers fully up to date. Good features yo.
      package = pkgs.bleeding.mesa;
      package32 = pkgs.bleeding.pkgsi686Linux.mesa;
    };
  };
}
