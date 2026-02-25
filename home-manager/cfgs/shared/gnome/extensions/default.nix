args@{ cfg, lib, pkgs, config, ... }:
let
  mkExt = package: uuid: { inherit package uuid; };
  fromPkg = package: mkExt package package.extensionUuid;

  # Central list for packages + extension UUIDs (keeps them in sync)
  extList = [
    (fromPkg pkgs.gnomeExtensions.appindicator)
    (fromPkg pkgs.gnomeExtensions.applications-overview-tooltip)
    (fromPkg pkgs.gnomeExtensions.astra-monitor)
    (fromPkg pkgs.gnomeExtensions.caffeine)
    (fromPkg pkgs.gnomeExtensions.just-perfection)
    (fromPkg pkgs.gnomeExtensions.rounded-window-corners-reborn)
    (fromPkg pkgs.gnomeExtensions.user-themes)

    (mkExt pkgs.gpaste "GPaste@gnome-shell-extensions.gnome.org")
  ];
in
{
  imports = map (mod: (import mod (args // { cfg = config.flake-configs.gnome.extensions; }))) [
    ./appindicator.nix
    ./applications-overview-tooltip.nix
    ./astra-monitor.nix
    ./caffeine.nix
    ./gpaste.nix
    ./just-perfection.nix
    ./rounded-window-corners.nix
    ./user-themes.nix
  ];

  options.flake-configs.gnome.extensions = {
    enable = lib.mkEnableOption "Enable GNOME extensions" // { default = cfg.enable; };
  };

  config = lib.mkIf config.flake-configs.gnome.extensions.enable {
    home.packages = map (e: e.package) extList;

    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = map (e: e.uuid) extList;
      };
    };
  };
}
