{ lib, config, pkgs, ... }@args:
let
  inherit (lib) mkEnableOption mkIf mkMerge mkDefault;
  cfg = config.flake-configs.dolphin;
  mkMenu = import ./mkMenu.nix args;
in
{
  options.flake-configs.dolphin = {
    enable = mkEnableOption "Dolphin configuration";
    setAsDefault = mkEnableOption "Set as default file explorer";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      qt.kde.settings.dolphinrc = {
        "KFileDialog Settings" = {
          "Places Icons Auto-resize" = false;
          "Places Icons Static Size" = 22;
        };
        General = {
          GlobalViewProps = false;
          RememberOpenedTabs = false;
          ShowFullPathInTitlebar = true;
          HomeUrl = config.home.homeDirectory;

          # Single-instance
          OpenExternallyCalledFolderInNewTab = true;

          # Allow specific folder sorting and whatnot
          ConfirmClosingMultipleTabs = false;

          # Short path in location unless expanded
          ShowFullPath = false;

          # Open compressed archives in dolphin directly
          BrowseThroughArchives = true;
        };
      };

      home.packages = [
        pkgs.kdePackages.dolphin

        # KIO - mostly for samba, but useful for many things
        pkgs.kdePackages.kio
        pkgs.kdePackages.kio-extras

        # Thumbnails
        pkgs.ffmpegthumbnailer

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
    }

    (mkIf cfg.setAsDefault {
      xdg.mimeApps = {
        enable = mkDefault true;
        defaultApplications = {
          "inode/directory" = "org.kde.dolphin.desktop";
        };
      };
    })
  ]);
}
