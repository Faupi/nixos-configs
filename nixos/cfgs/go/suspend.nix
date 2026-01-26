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
            echo 3 > /proc/sys/vm/drop_caches || true
            echo 1 > /proc/sys/vm/compact_memory || true

            logger -t "$name" "Calculating image size for $action"
            memfree_kb="$(awk '/^MemFree:/ {print $2}' /proc/meminfo)"
            reserve_bytes=$((1024 * 1024 * 1024))
            target_bytes=$((memfree_kb * 1024 * 80 / 100 - reserve_bytes))

            min_bytes=$((512 * 1024 * 1024))
            [ "$target_bytes" -lt "$min_bytes" ] && target_bytes="$min_bytes"

            logger -t "$name" "Setting image size for $action: $target_bytes bytes"
            echo "$target_bytes" > /sys/power/image_size
            ;;
        esac
      '';
    });
}
