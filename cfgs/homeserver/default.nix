{ config, pkgs, lib, ... }: {
  imports = [
    ./boot.nix
    ./hardware.nix
    ./octoprint
  ];

  networking.networkmanager.enable = true;
  networking.hostName = "homeserver";

  services.openssh.enable = true;

  users.users.faupi = {
    isNormalUser = true;
    description = "Faupi";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAXCxrSb0+rjhKkU6l/4R226O/M3xq3iosfMlRWyayUU23zr/eBKq0YKQGPEkRK7a6cOOPXE7uKZ+BXkxX6aIDpp/s5W76GElUI886wU82j7bR/msVf/LN8SpnOVl4ZptNo3bvc2zlUNHXChXYJ9aVoU5dW755G8vsfE6mtCQy2F2Ju4f8l4g23O9hOpTFdjcefjUaRkD5TOV315/cOW5HVzyI5poW4RmDA60A1wddDlXadjJPiI+wrSZofc4iwORI1lXCcz+5Qmy3VrQrOa7Jxzgj5ibvAYB/8KH7wpd6Ik3ZbOVrax1ME7KUiN/DRY9ybOTfDGF13CV8wpNzSjoD faupi@Faupi-PC"
    ];
  };

  # TODO: Move to a base config [[
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.shellAliases = {
    nixconf="nano /etc/nixos/configuration.nix";
    nixreload="nix flake update github:Faupi/home-nix; nixos-rebuild switch --flake github:Faupi/home-nix; exec bash";
    octoconf="nano /var/lib/octoprint/config.yaml";
  };

  programs.nano.nanorc = ''
    set tabstospaces
    set tabsize 2
  '';
  # TODO: ]] --end-- 

  system.stateVersion = "22.11"; # Did you read the comment?
}
