{ config, pkgs, lib, fop-utils, ... }:
{
  imports = [
    ./boot.nix
    ./quirks.nix
    # ./remote-builders.nix # TODO: Enable when homeserver is back online
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
  nix.gc = fop-utils.mkDefaultRecursively {
    automatic = false;
    options = "--delete-older-than 14d";
    randomizedDelaySec = "10m"; # Delay so it doesn't block boot
  };

  # Auto-upgrade
  system.autoUpgrade = fop-utils.mkDefaultRecursively {
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
        LimitNOFILE = lib.mkForce "infinity";

        # Limit resources so it doesn't hang the system
        CPUWeight = [ "20" ];
        # CPUQuota = [ "85%" ];
        IOWeight = [ "20" ]; # Lower for background work

        # Let other processes take priority if needed
        Nice = 5;
      };
    in
    lib.mkMerge [
      {
        # Builder
        nix-daemon.serviceConfig = builderServiceConfig;
      }

      # Auto-upgrade
      (lib.mkIf (config.system.autoUpgrade.enable) {
        nixos-upgrade.serviceConfig = builderServiceConfig;
      })
    ];

  # Enable all the firmware™
  hardware.enableAllFirmware = true;

  # DHCP
  networking.useDHCP = lib.mkDefault true;

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

  # Shell
  users.defaultUserShell = with pkgs;
    zsh;
  environment = {
    shells = [ config.users.defaultUserShell ];
    pathsToLink = [ "/share/zsh" ]; # Auto-completion
  };
  programs.command-not-found.enable = true;
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
  };
  # Password feedback for sudo
  security.sudo.extraConfig = ''
    Defaults pwfeedback
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
    # Automatically resolve existing files to backup
    # Add timestamp to avoid collisions: https://discourse.nixos.org/t/nixos-rebuild-fails-on-backup-up-config-file-by-home-manager/45992/2
    backupFileExtension = "backup-" + (builtins.readFile "${pkgs.runCommand "timestamp" {} "echo -n `date '+%Y%m%d%H%M%S'` > $out"}");
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
    options = lib.mkForce ""; # fuck terminate fuck terminate fuck fuck FUCK WHY IS IT A DEFAULT
  };

  # Link up /bin/bash
  system.activationScripts.binbash = {
    deps = [ "binsh" ];
    text = ''
      ln -sf /bin/sh /bin/bash
    '';
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor-nerdfonts
  ];
}
