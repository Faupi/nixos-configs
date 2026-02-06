{ pkgs, lib, ... }: {
  boot.kernelParams = [
    "mem_sleep_default=s2idle"
    "amdgpu.dcdebugmask=0x10" # Disable Panel Self Refresh (PSR) - seems to have resolved issues with GPU wake-up
    "amdgpu.dc=1" # Forces full display core path (apparently for s2idle correctness)
    "hibernate.compressor=lz4" # Compress hibernation image
  ];

  services.udev.extraRules = ''
    # Disable "wake on USB" for HID - generally fine to keep to avoid random wake-ups
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

    # Disable wake-up on charger connect/disconnect/whatever
    SUBSYSTEM=="platform", KERNEL=="USBC*", ATTR{power/wakeup}="disabled"
  '';

  boot.resumeDevice = "/dev/disk/by-label/NIXSWAP";

  /* NOTE: Using powerbuttond, which specifically triggers suspend.
           This is a dirty solution, but if it works, it works. */
  systemd.services."systemd-suspend".overrideStrategy = "asDropin";
  systemd.services."systemd-suspend".serviceConfig = {
    ExecStart = [
      # Clear
      ""
      # Replace with suspend-then-hibernate
      "${pkgs.systemd}/lib/systemd/systemd-sleep suspend-then-hibernate"
    ];
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=15min
  '';

  environment.etc."systemd/system-sleep/20-pre-hibernate".source =
    lib.getExe (pkgs.writeShellApplication rec {
      name = "pre-hibernate";
      runtimeInputs = with pkgs; [
        util-linux # logger
        coreutils # sync
        gawk # awk
      ];
      runtimeEnv = { inherit name; };
      text = /*sh*/''
        phase="$1"
        action="$2"
        stage="''${SYSTEMD_SLEEP_ACTION:-}"

        is_hibernation() {
          [ "$action" = "hibernate" ] && return 0
          [ "$action" = "suspend-then-hibernate" ] && [ "$stage" = "hibernate" ] && return 0
          return 1
        }

        case "$phase" in
          pre)
            is_hibernation || exit 0

            logger -t "$name" "Freeing memory for $action"
            sync
            echo 3 > /proc/sys/vm/drop_caches || logger -t "$name" "drop_caches failed (continuing)"
            echo 1 > /proc/sys/vm/compact_memory || logger -t "$name" "compact_memory failed (continuing)"

            # Make the system figure out the image size automatically
            echo 0 > /sys/power/image_size || logger -t "$name" "write image_size failed (continuing)"

            udevadm settle --timeout=5 || udevadm settle --timeout=10 || logger -t "$name" "udevadm settle failed (continuing)"
            ;;
        esac
      '';
    });
}
