/* 
  Leverage power profiles to make suspend less taxing on battery (s2idle) 
  and hibernation computing in a reasonable time
*/

{ pkgs, lib, config, ... }: {
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
    kernelModules = [ "acpi_call" ];
    initrd.kernelModules = [ "acpi_call" ];
  };

  environment.etc."systemd/system-sleep/10-power-profiles".source =
    lib.getExe (pkgs.writeShellApplication rec {
      name = "power-profiles";
      runtimeInputs = with pkgs;[
        coreutils
        util-linux
        gnused
        kmod
      ];
      runtimeEnv = { inherit name; };
      text = /*sh*/''
        set +e
        log() {
          logger -t "$name" "$1"
        }

        # shellcheck disable=SC2034
        {
          QUIET="01"
          BALANCED="02"
          PERFORMANCE="03"
        }

        phase="$1";
        action="$2";
        stage="''${SYSTEMD_SLEEP_ACTION:-}"

        log "phase=$phase action=$action stage=$stage"
      
        run_quick() {
          # $1 seconds, rest command
          t="$1"; shift
          timeout "$t" "$@" >/dev/null 2>&1 || true
          return 0
        }

        # ---- ACPI call helpers ----
        ensure_acpi_call() {
          run_quick 0.2 modprobe acpi_call
          run_quick 0.2 udevadm settle
          [ -w /proc/acpi/call ] || return 1
          return 0
        }

        acpi_write_line() {
          [ -w /proc/acpi/call ] || return 1
          line="$1"
          printf '%s\n' "$line" > /proc/acpi/call 2>/dev/null || true
          return 0
        }

        acpi_read_first_hex() {
          [ -r /proc/acpi/call ] || return 1
          cat /proc/acpi/call 2>/dev/null | sed -n 's/.*\(0x[0-9A-Fa-f]\+\).*/\1/p' | head -n1
        }

        # shellcheck disable=SC2329
        log_acpi_call() {
          # Send whatever /proc/acpi/call contains to journald without command substitution.
          if [ -r /proc/acpi/call ]; then
            tr '\000' '?' < /proc/acpi/call 2>/dev/null | logger -t "$name" || true
          fi
        }

        get_tdp_hexbyte() {
          # Trigger read: \_SB.GZFD.WMAA [0, 0x2D, 0]
          acpi_write_line '\_SB.GZFD.WMAA 0x00 0x2d 0x00'
          raw="$(acpi_read_first_hex 2>/dev/null || true)"
          [ -n "$raw" ] || return 1
          v="$((raw))" 2>/dev/null || return 1
          printf '%02x\n' "$v"
        }

        set_tdp_hexbyte() {
          # Set: \_SB.GZFD.WMAA [0, 0x2C, b]
          b="$1"
          acpi_write_line '\_SB.GZFD.WMAA 0x00 0x2c 0x'"$b"
          return 0
        }

        # Direct utils
        save_profile() {
          if [ ! -e /run/old_tdp_hexbyte ]; then
            old="$(get_tdp_hexbyte 2>/dev/null || true)"
            log "Saving current profile: $old"
            [ -n "$old" ] && printf '%s\n' "$old" > /run/old_tdp_hexbyte
          fi
        }

        restore_profile() {
          if [ -r /run/old_tdp_hexbyte ]; then
            old="$(cat /run/old_tdp_hexbyte 2>/dev/null || log "Could not read previous profile")"
            rm -f /run/old_tdp_hexbyte 2>/dev/null || true
            if [ -n "$old" ]; then 
              log "Switching to previous profile: $old"
              set_tdp_hexbyte "$old"
            fi
          fi
        }

        if ! ensure_acpi_call; then
          log "ERROR: ACPI calls cannot be made"
          exit 1
        fi

        case "$phase:$action:$stage" in
          # Suspend always power-saving due to firmware quirks
          pre:suspend:* | \
          pre:suspend-then-hibernate:suspend)
            save_profile
            log "Switching to quiet profile"
            set_tdp_hexbyte "$QUIET"
            ;;

          # Boost hibernate processing with performance mode
          pre:hibernate:* | \
          pre:suspend-then-hibernate:hibernate)
            save_profile
            log "Switching to performance profile"
            set_tdp_hexbyte "$PERFORMANCE"
            ;;

          # Restore in any case
          post:suspend:* | \
          post:suspend-then-hibernate:suspend | \
          post:hibernate:* | \
          post:suspend-then-hibernate:hibernate)
            restore_profile
            ;;
        esac
      '';
    });
}
