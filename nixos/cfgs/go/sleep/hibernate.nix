{ pkgs, lib, ... }: {
  boot = {
    resumeDevice = "/dev/disk/by-label/NIXSWAP";
    kernelParams = [
      "hibernate.compressor=lz4" # Compress hibernation image
    ];
  };

  # Hibernate on normal suspend calls too
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

  # Main logic to handle memory cleanup and clean hibernation
  # TODO: Still needs to be more robust
  environment.etc."systemd/system-sleep/20-hibernate-stability".source =
    lib.getExe (pkgs.writeShellApplication rec {
      name = "hibernate-stability";
      runtimeInputs = with pkgs; [
        util-linux # logger
        coreutils # sync
        gawk # awk
      ];
      runtimeEnv = { inherit name; };
      text = /*sh*/''
        set +e

        phase="$1"
        action="$2"
        stage="''${SYSTEMD_SLEEP_ACTION:-}"

        log() {
          logger -t "$name" "$1"
        }

        case "$phase:$action:$stage" in
          pre:hibernate: | \
          pre:suspend-then-hibernate:hibernate)
            log "Freeing memory for $action"
            sync
            echo 3 > /proc/sys/vm/drop_caches || 
              log "drop_caches failed (continuing)"
            echo 1 > /proc/sys/vm/compact_memory || 
              log "compact_memory failed (continuing)"

            logger -t "$name" "Calculating image size for $action"
            memfree_kb="$(awk '/^MemFree:/ {print $2}' /proc/meminfo)"
            reserve_bytes=$((1 * 1024 * 1024 * 1024))
            target_bytes=$((memfree_kb * 1024 * 50 / 100 - reserve_bytes))

            min_bytes=$((512 * 1024 * 1024))
            [ "$target_bytes" -lt "$min_bytes" ] && target_bytes="$min_bytes"

            logger -t "$name" "Setting image size for $action: $target_bytes bytes"
            echo "$target_bytes" > /sys/power/image_size || logger -t "$name" "write image_size failed (continuing)"
                
            # Save & bump swappiness temporarily (only once)
            if [ -r /proc/sys/vm/swappiness ] && [ ! -r /run/old_swappiness ]; then
              cat /proc/sys/vm/swappiness > /run/old_swappiness 2>/dev/null || true
              echo 180 > /proc/sys/vm/swappiness 2>/dev/null || 
                log "write swappiness failed (continuing)"
            fi
            # Give the VM a moment to actually reclaim/swap
            sleep 2

            udevadm settle --timeout=5 || udevadm settle --timeout=10 || 
              log "udevadm settle failed (continuing)"
            ;;

          post:hibernate: | \
          post:suspend-then-hibernate:hibernate)
            if [ -r /run/old_swappiness ]; then
              cat /run/old_swappiness > /proc/sys/vm/swappiness 2>/dev/null || true
              rm -f /run/old_swappiness
            fi
        esac
      '';
    });
}
