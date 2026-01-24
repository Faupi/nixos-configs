{ pkgs, lib, ... }: {
  boot.kernelParams = [
    "mem_sleep_default=s2idle"
    "amdgpu.dcdebugmask=0x10" # Disable Panel Self Refresh (PSR) - seems to have resolved issues with GPU wake-up
    "amdgpu.dc=1" # Forces full display core path (apparently for s2idle correctness)
    "hibernate.compressor=lzo" # Compress hibernation image
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

  # Drop caches before hibernation - avoids insufficient memory issues
  environment.etc."systemd/system-sleep/20-pre-hibernate-cleanup".source =
    lib.getExe (pkgs.writeShellApplication rec {
      name = "pre-hibernate-cleanup";
      runtimeInputs = with pkgs; [ util-linux coreutils ];
      runtimeEnv = { inherit name; };
      text = /*sh*/''
        phase="$1"
        action="$2"
        case "$phase:$action" in
          pre:hibernate|pre:suspend-then-hibernate)
            logger -t "$name" "Dropping caches before $action"
            sync
            echo 3 > /proc/sys/vm/drop_caches || true
            ;;
        esac
      '';
    });
}
