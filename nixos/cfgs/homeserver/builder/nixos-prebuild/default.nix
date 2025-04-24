{ pkgs, ... }: {
  systemd.services.nixos-prebuild = {
    enable = true;
    description = "Prebuilder for flake systems";
    startAt = "2:00";
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = ./service.sh;
    };
    path = with pkgs; [
      coreutils
      jq
      nix
      nix-fast-build
    ];
  };

  services.notify-email.services = [ "nixos-prebuild" ];
}
