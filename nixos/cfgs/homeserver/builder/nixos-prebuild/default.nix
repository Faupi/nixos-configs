{ pkgs, lib, ... }:
let
  #TODO: Patch shebangs and whatnot
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
      ExecStartPre = ''
        ${lib.getExe pkgs.bash} -c '[ -d /srv/nixos-prebuild ] || ${lib.getExe pkgs.git} clone https://github.com/faupi/nixos-configs /srv/nixos-prebuild'
      '';
      ExecStart = lib.getExe nixos-prebuild;
      Nice = 5;
    };
    path = with pkgs; [
      coreutils
      jq
      nix
      nix-fast-build
      git
    ];
  };

  services.notify-email.services = [ "nixos-prebuild" ];
}
