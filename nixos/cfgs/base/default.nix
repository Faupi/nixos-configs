{ config, pkgs, lib, fop-utils, ... }:
{
  imports = [
    ./boot.nix
    ./quirks.nix
    ./remote-builders.nix
  ];

  nix.package = pkgs.stable.nixVersions.nix_2_25;

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
      "https://nix-gaming.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "jovian-nixos.cachix.org-1:mAWLjAxLNlfxAnozUjOqGj4AxQwCl7MXwOfu7msVlAo="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];

    max-substitution-jobs = 128;
  };

  # Auto GC and optimizations
  nix.optimise.automatic = true;
  nix.gc = fop-utils.mkDefaultRecursively {
    automatic = false;
    options = "--delete-older-than 14d";
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
    {
      # Auto-upgrade
      nixos-upgrade.serviceConfig = builderServiceConfig;

      # Builder
      nix-daemon.serviceConfig = builderServiceConfig;
    };

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
    backupFileExtension = "backup"; # Automatically resolve existing files to backup
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
}
