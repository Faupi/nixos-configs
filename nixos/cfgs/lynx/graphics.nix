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

    # Display seems to come back disabled after a system suspend+resume, we need to reset it on resume
    etc."systemd/system-sleep/20-virtual-display-reset".source =
      lib.getExe (pkgs.writeShellApplication rec {
        name = "virtual-display-reset";
        runtimeInputs = with pkgs; [
          coreutils
          util-linux
          wlr-randr
        ];
        runtimeEnv = { inherit name; };
        text = /*sh*/ ''
          set +e

          log() {
            logger -t "$name" "$1"
          }

          phase="$1"
          action="$2"
          stage="''${SYSTEMD_SLEEP_ACTION:-}"

          case "$phase:$action:$stage" in
            post:suspend:* | \
            post:suspend-then-hibernate:suspend)

              log "Waiting for gamestream Wayland session"

              uid="$(id -u gamestream 2>/dev/null)" || exit 0

              for _ in $(seq 1 30); do
                [ -S "/run/user/$uid/wayland-0" ] && break
                sleep 1
              done

              if [ ! -S "/run/user/$uid/wayland-0" ]; then
                log "wayland-0 not found, skipping"
                exit 0
              fi

              log "Resetting Virtual-1"

              runuser -u gamestream -- env \
                XDG_RUNTIME_DIR="/run/user/$uid" \
                WAYLAND_DISPLAY="wayland-0" \
                wlr-randr --output Virtual-1 --off

              sleep 1

              runuser -u gamestream -- env \
                XDG_RUNTIME_DIR="/run/user/$uid" \
                WAYLAND_DISPLAY="wayland-0" \
                wlr-randr \
                  --output Virtual-1 \
                  --on

              log "Virtual-1 reset complete"
              ;;
          esac
        '';
      });
  };

  boot = {
    kernelModules = [
      "amdgpu"
    ];
    kernelParams = [
      "amdgpu.virtual_display=0000:09:00.0,1" # Expose one virtual display

      # Attempts at resolving suspend/resume issues below:
      "amdgpu.dc=0"
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
