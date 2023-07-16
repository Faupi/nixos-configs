{ config, pkgs, lib, ... }: {
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.nano.nanorc = ''
    set tabstospaces
    set tabsize 2
  '';

  environment.shellAliases = {
    nixconf = "nano /etc/nixos/configuration.nix";
    nixreload = "nix flake update github:Faupi/nixos-configs; nixos-rebuild switch --flake github:Faupi/nixos-configs; exec bash";
  };

  # User
  users.users.faupi = {
    isNormalUser = true;
    description = "Faupi";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAXCxrSb0+rjhKkU6l/4R226O/M3xq3iosfMlRWyayUU23zr/eBKq0YKQGPEkRK7a6cOOPXE7uKZ+BXkxX6aIDpp/s5W76GElUI886wU82j7bR/msVf/LN8SpnOVl4ZptNo3bvc2zlUNHXChXYJ9aVoU5dW755G8vsfE6mtCQy2F2Ju4f8l4g23O9hOpTFdjcefjUaRkD5TOV315/cOW5HVzyI5poW4RmDA60A1wddDlXadjJPiI+wrSZofc4iwORI1lXCcz+5Qmy3VrQrOa7Jxzgj5ibvAYB/8KH7wpd6Ik3ZbOVrax1ME7KUiN/DRY9ybOTfDGF13CV8wpNzSjoD faupi@Faupi-PC"
    ];
  };

  # Localization
  time.timeZone = "Europe/Prague";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "cs_CZ.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "cs_CZ.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # X11 keymap
  services.xserver = {
    layout = "us";
    xkbVariant = "mac";
  };
}