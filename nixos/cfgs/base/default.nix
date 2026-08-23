{ config, pkgs, lib, inputs, fop-utils, homeManagerModules, ... }:
let
  inherit (lib) mkIf mkMerge mkForce;
in
rec {
  imports = [
    ./auto-upgrade.nix
    ./boot.nix
    ./hardware.nix
    ./input.nix
    ./network.nix
    ./nix.nix
    ./quirks.nix
    # ./remote-builders.nix # TODO: Enable when homeserver is back online
    ./shell.nix
  ];

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

  # Sops
  # Automatic import of host keys
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.pw-faupi.neededForUsers = true;

  # User
  users.users.faupi = {
    isNormalUser = true;
    description = "Faupi";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPasswordFile = config.sops.secrets.pw-faupi.path;
  };
  home-manager = {
    useGlobalPkgs = false; # Use pkgs defined specifically for the user
    useUserPackages = true; # Better flow for NixOS activation

    # Usually redundant thanks to mkHome, but direct home-manager definitions with module imports might fail otherwise. Keep in sync with baseArgs in mkHome in flake-utils.nix
    extraSpecialArgs = {
      inherit inputs fop-utils homeManagerModules;
    };

    # Move conflicting files to a unique name in-place to avoid collisions.
    backupCommand = pkgs.writeShellScript "home-manager-backup" /*sh*/''
      set -euo pipefail
      target="$1"

      # If the existing file is a symlink into the Nix store, just remove it instead of creating another backup.
      if [ -L "$target" ]; then
        resolved="$(readlink -f -- "$target")"
        if [[ "$resolved" == /nix/store/* ]]; then
          rm -- "$target"
          exit 0
        fi
      fi

      dir="$(dirname "$target")"
      base="$(basename "$target")"
      stamp="$(date +%Y%m%d%H%M%S)"
      backup="$(mktemp --tmpdir="$dir" "$base.backup-$stamp-XXXXXXXX")"
      mv -- "$target" "$backup"
    '';
  };

  # Localization
  time.timeZone = "Europe/Prague";
  environment.sessionVariables.TZ = time.timeZone; # Discord/Electron takes TZ specifically for some reason
  i18n = {
    defaultLocale = "en_DK.UTF-8";
    extraLocaleSettings = {
      LC_MESSAGES = "en_US.UTF-8"; # keep UI/messages in English
      LC_MONETARY = "sk_SK.UTF-8"; # euros
      LC_NUMERIC = "en_IE.UTF-8"; # decimal dot (1234.56)
      LC_TIME = "en_IE.UTF-8"; # date/time (2026-04-20, 13:37)
      LC_MEASUREMENT = "cs_CZ.UTF-8"; # metric units
      LC_PAPER = "cs_CZ.UTF-8";
      LC_ADDRESS = "cs_CZ.UTF-8";
      LC_TELEPHONE = "cs_CZ.UTF-8";
    };
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
    (nix-output-monitor-nerdfonts.override { inherit (pkgs.unstable) nix-output-monitor; })
  ];

  # Semi-strict journal spam prevention
  # mainly here to stop some majorly-errored services from hanging up the system
  services.journald.extraConfig = ''
    RateLimitIntervalSec=30s
    RateLimitBurst=1500
  '';
}
