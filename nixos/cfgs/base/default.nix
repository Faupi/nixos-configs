{ config, pkgs, lib, fop-utils, ... }:
let
  inherit (lib) mkIf mkMerge mkDefault mkForce;
  inherit (fop-utils) mkDefaultRecursively;
in
{
  imports = [
    ./boot.nix
    ./quirks.nix
    # ./remote-builders.nix # TODO: Enable when homeserver is back online
    ./shell.nix
  ];

  nix.package = pkgs.lix;

  # Package policies + cache
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];

    substituters = [
      "https://nix-community.cachix.org"
      "https://jovian-nixos.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "jovian-nixos.cachix.org-1:mAWLjAxLNlfxAnozUjOqGj4AxQwCl7MXwOfu7msVlAo="
    ];

    max-substitution-jobs = 128;
  };

  # Auto GC and optimizations
  nix.optimise.automatic = true;
  nix.gc = mkDefaultRecursively {
    automatic = false;
    options = "--delete-older-than 14d";
    randomizedDelaySec = "10m"; # Delay so it doesn't block boot
  };

  # Auto-upgrade
  system.autoUpgrade = mkDefaultRecursively {
    enable = false;
    operation = "switch";
    flake = "github:Faupi/nixos-configs";
    flags = [ "--refresh" "--no-update-lock-file" ];

    dates = "4:30";
    allowReboot = true;
    rebootWindow = {
      lower = "05:00";
      upper = "07:00";
    };
  };

  # Builder services
  systemd.services =
    let
      builderServiceConfig = {
        # Workaround for "too many files open" for building | https://discourse.nixos.org/t/unable-to-fix-too-many-open-files-error/27094
        LimitNOFILE = mkForce "infinity";

        # Limit resources so it doesn't hang the system
        CPUWeight = [ "20" ];
        # CPUQuota = [ "85%" ];
        IOWeight = [ "20" ]; # Lower for background work

        # Let other processes take priority if needed
        Nice = 5;
      };
    in
    mkMerge [
      {
        # Builder
        nix-daemon.serviceConfig = builderServiceConfig;
      }

      # Auto-upgrade
      (mkIf (config.system.autoUpgrade.enable) {
        nixos-upgrade.serviceConfig = builderServiceConfig;
      })
    ];

  # Enable all the firmware™
  hardware.enableAllFirmware = true;

  # DHCP
  networking.useDHCP = mkDefault true;

  # Resolved DNS
  services.resolved.enable = mkDefault true;

  # Sops
  # Automatic import of host keys
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.pw-faupi.neededForUsers = true;

  # Nano unified
  programs.nano.nanorc = ''
    set tabstospaces
    set tabsize 2
  '';

  # User
  users.users.faupi = {
    isNormalUser = true;
    description = "Faupi";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPasswordFile = config.sops.secrets.pw-faupi.path;
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Move conflicting files to a unique name in-place to avoid collisions.
    backupCommand = pkgs.writeShellScript "home-manager-backup" /*sh*/''
      set -euo pipefail
      target="$1"
      dir="$(dirname "$target")"
      base="$(basename "$target")"
      stamp="$(date +%Y%m%d%H%M%S)"
      backup="$(mktemp --tmpdir="$dir" "$base.backup-$stamp-XXXXXXXX")"
      mv "$target" "$backup"
    '';
  };

  # Localization
  time.timeZone = "Europe/Prague";
  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_MONETARY = "sk_SK.UTF-8"; # euros and whatnot
    LC_NUMERIC = "en_US.UTF-8"; # dot for decimal separator
    LC_TIME = "en_IE.UTF-8"; # en_DK time dot bad
  };

  # X11 keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "mac";
    options = mkForce ""; # fuck terminate fuck terminate fuck fuck FUCK WHY IS IT A DEFAULT
  };

  # Link up /bin/bash
  system.activationScripts.binbash = {
    deps = [ "binsh" ];
    text = ''
      ln -sf /bin/sh /bin/bash
    '';
  };

  environment.pathsToLink = [
    "/share/kio"
  ];
  environment.systemPackages = with pkgs; [
    nix-output-monitor-nerdfonts
  ];

  # Semi-strict journal spam prevention
  # mainly here to stop some majorly-errored services from hanging up the system
  services.journald.extraConfig = ''
    RateLimitIntervalSec=30s
    RateLimitBurst=1500
  '';

  # Apply a default mouse profile
  services.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
      accelSpeed = "-0.9";
    };
  };
}
