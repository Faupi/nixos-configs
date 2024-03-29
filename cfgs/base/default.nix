{ config, pkgs, lib, fop-utils, ... }:
with lib;
{
  imports = [
    ./boot.nix
    ./quirks.nix
    ./remote-builders.nix
  ];

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
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://jovian-nixos.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "jovian-nixos.cachix.org-1:mAWLjAxLNlfxAnozUjOqGj4AxQwCl7MXwOfu7msVlAo="
    ];
  };

  # Auto GC and optimizations
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = mkDefault false;
    options = "--delete-older-than 7d";
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
  systemd.services.nixos-upgrade.serviceConfig = {
    # Workaround for "too many files open" for building | https://discourse.nixos.org/t/unable-to-fix-too-many-open-files-error/27094
    LimitNOFILE = mkForce "infinity";

    # Limit resources so it doesn't hang the system
    CPUWeight = [ "20" ];
    # CPUQuota = [ "85%" ];
    IOWeight = [ "20" ]; # Lower for background work
  };

  # Building
  systemd.services.nix-daemon.serviceConfig = {
    # Workaround for "too many files open" for building | https://discourse.nixos.org/t/unable-to-fix-too-many-open-files-error/27094
    LimitNOFILE = mkForce "infinity";

    # Limit resources so it doesn't hang the system
    CPUWeight = [ "20" ];
    # CPUQuota = [ "85%" ];
    IOWeight = [ "50" ];
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
  programs.command-not-found.enable = true;
  environment = {
    shells = [ pkgs.zsh ];
    pathsToLink = [ "/share/zsh" ]; # Auto-completion
  };
  users.defaultUserShell = pkgs.zsh;
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
    options = mkForce ""; # fuck terminate fuck terminate fuck fuck FUCK WHY IS IT A DEFAULT
  };

  # Sops secrets
  # TODO: Move to where it's actually needed
  sops.secrets = {
    steamgrid-api-key = {
      group = "users";
      mode = "0440"; # users group
    };
  };
}
