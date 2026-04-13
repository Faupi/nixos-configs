{ lib, config, pkgs, ... }@args:
let
  cfg = config.flake-configs.dolphin;
  mkMenu = import ./mkMenu.nix args;
in
{
  options.flake-configs.dolphin = {
    enable = lib.mkEnableOption "Dolphin configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.kdePackages.dolphin

      # KIO - mostly for samba, but useful for many things
      pkgs.kdePackages.kio
      pkgs.kdePackages.kio-extras

      (mkMenu {
        name = "defer-link";
        title = "Convert symlink to regular file";
        icon = "edit-copy";
        script = ./deref-link.sh;
        mimeTypes = [
          "inode/symlink"
          "application/octet-stream"
        ];
        extraDesktopConfig = {
          X-KDE-Protocols = "file";
        };
      })
    ];
  };
}
