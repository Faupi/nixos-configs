{ pkgs, lib, ... }:
let
  nixos-prebuild = pkgs.writeShellScriptBin "nixos-prebuild" (builtins.readFile ./service.sh);
in
{
  environment.systemPackages = [
    nixos-prebuild
  ];

  systemd.services.nixos-prebuild = {
    enable = true;
    description = "Prebuilder for flake systems";
    startAt = "2:00";
    after = [ "network.target" ];
    before = [ "nixos-upgrade.service" "nixos-store-optimize.service" ]; # Make sure that stuff is prebuilt before doing more automated nix store things
    serviceConfig = {
      WorkingDirectory = "/srv/nixos-configs";
      ExecStartPre = ''
        ${pkgs.bash}/bin/bash -c '
          if [ ! -d /srv/nixos-configs ]; then
            git clone https://github.com/faupi/nixos-configs /srv/nixos-configs
          fi
        '
      '';
      ExecStart = lib.getExe nixos-prebuild;
      Nice = 5;
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
