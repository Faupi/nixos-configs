{ pkgs, lib, config, ... }: {
  environment = {
    sessionVariables = {
      # Upgrade FSR 3.1+ to FSR4 automatically
      PROTON_FSR4_UPGRADE = 1;

      # Set up a custom layout order
      # NOTE: The layers get explicitly enabled with this variable 
      #       - To disable them, their "Disable Env Var" must be used (VK_LOADER_DEBUG=layer %command%)
      # NOTE: Wildcards can be used, e.g. `VK_LAYER_MANGOHUD_overlay_*`
      # VK_LOADER_LAYERS_ENABLE = concatStringsSep "," [
      #   # Loads closer to vulkan app
      #   "VK_LAYER_MANGOHUD_overlay_*"
      #   "VK_LAYER_LSFGVK_frame_generation"
      #   "VK_LAYER_MESA_anti_lag"
      #   # Loads closer to vulkan driver
      # ];
      # Flags implied by enabling above
      ENABLE_LAYER_MESA_ANTI_LAG = 1; # Improves latency (mesa 25.3+)
      MANGOHUD = 1;
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
    kernelParams = [
      "amdgpu.virtual_display=0000:09:00.0,1" # Expose one virtual display
    ];
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Specialization for debugging that disables the virtual display - allows external monitors
  specialisation.no-virtual-display.configuration = {
    boot.kernelParams = lib.mkForce (
      builtins.filter
        (p: !(lib.hasPrefix "amdgpu.virtual_display=" p))
        config.boot.kernelParams
    );
  };

  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
