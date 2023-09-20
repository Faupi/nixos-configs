{ config, pkgs, lib, ... }: 
let 
  sharedShellLibs = builtins.toFile "shared-lib.sh" ''
    nixreload() {
      sudo nixos-rebuild switch --flake github:Faupi/nixos-configs --refresh --no-update-lock-file "$@"
    }
  '';
in
{
  imports = [
    ./quirks.nix
    ./remote-builders.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
    
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
  nix.gc.automatic = lib.mkDefault false;
  nix.gc.options = "--delete-older-than 7d";

  # Nano unified
  programs.nano.nanorc = ''
    set tabstospaces
    set tabsize 2
  '';

  # Shell
  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    interactiveShellInit = "source ${sharedShellLibs}";
  };
  programs.bash.interactiveShellInit = "source ${sharedShellLibs}";  # In case bash is still used

  # User
  users.users.faupi = {
    isNormalUser = true;
    description = "Faupi";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAXCxrSb0+rjhKkU6l/4R226O/M3xq3iosfMlRWyayUU23zr/eBKq0YKQGPEkRK7a6cOOPXE7uKZ+BXkxX6aIDpp/s5W76GElUI886wU82j7bR/msVf/LN8SpnOVl4ZptNo3bvc2zlUNHXChXYJ9aVoU5dW755G8vsfE6mtCQy2F2Ju4f8l4g23O9hOpTFdjcefjUaRkD5TOV315/cOW5HVzyI5poW4RmDA60A1wddDlXadjJPiI+wrSZofc4iwORI1lXCcz+5Qmy3VrQrOa7Jxzgj5ibvAYB/8KH7wpd6Ik3ZbOVrax1ME7KUiN/DRY9ybOTfDGF13CV8wpNzSjoD faupi@Faupi-PC"
    ];
    hashedPassword = "$y$j9T$BFox9d4.qg4UNVv6VnOlH1$xWM7OZO7bNn8KCs2umIR/q4sGLUFfZMOWYkBylKPa/D";
  };

  # Localization
  time.timeZone = "Europe/Prague";
  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_MONETARY = "sk_SK.UTF-8";  # euros and whatnot
    LC_NUMERIC = "en_US.UTF-8";   # dot for decimal separator
    LC_TIME = "en_IE.UTF-8";      # en_DK time dot bad
  };

  # X11 keymap
  services.xserver = {
    layout = "us";
    xkbVariant = "mac";
    xkbOptions = lib.mkForce "";  # fuck terminate fuck terminate fuck fuck FUCK WHY IS IT A DEFAULT
  };

  # Workaround for "too many files open" for building | https://discourse.nixos.org/t/unable-to-fix-too-many-open-files-error/27094
  systemd.services.nix-daemon.serviceConfig.LimitNOFILE = lib.mkForce "infinity";
}
