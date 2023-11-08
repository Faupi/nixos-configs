{ pkgs, lib, ... }:
with lib; {
  imports = [ ./quirks.nix ./remote-builders.nix ];

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

    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

    ];
  };

  # Auto GC and optimizations
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = mkDefault false;
    options = "--delete-older-than 7d";
  };

  # Auto-upgrade
  system.autoUpgrade = {
    enable = mkDefault false;
    flake = "github:Faupi/nixos-configs";
    flags = [ "--refresh" "--no-update-lock-file" ];
    allowReboot = mkDefault true;
    rebootWindow = {
      lower = "03:00";
      upper = "06:00";
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

  # Sops
  # Automatic import of host keys
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets.yaml;

  # Nano unified
  programs.nano.nanorc = ''
    set tabstospaces
    set tabsize 2
  '';

  # Shell
  programs.command-not-found.enable = true;
  environment.shells = [ pkgs.zsh ];
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
    hashedPassword =
      "$y$j9T$BFox9d4.qg4UNVv6VnOlH1$xWM7OZO7bNn8KCs2umIR/q4sGLUFfZMOWYkBylKPa/D";
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
  services.xserver = {
    layout = "us";
    xkbVariant = "mac";
    xkbOptions = mkForce
      ""; # fuck terminate fuck terminate fuck fuck FUCK WHY IS IT A DEFAULT
  };

  # Sops secrets
  # TODO: make betterer?
  sops.secrets = {
    steamgrid-api-key = {
      group = "users";
      mode = "0440"; # users group
    };
  };
}
