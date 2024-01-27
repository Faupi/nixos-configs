{ pkgs, fop-utils, ... }:
let
  ddcutil = ''${pkgs.ddcutil}/bin/ddcutil --model "24G1WG4"''; # Targeted to external monitor
  dbusDestination = "faupi.MonitorInputSwitcher";
  dbusPath = "/faupi/MonitorInputSwitcher";
  dbusInterface = dbusDestination;

  monitorInputSwitcher = with pkgs; substituteAll {
    src = ./switch-monitor-input.sh;
    isExecutable = true;
    inherit bash ddcutil;
  };
  dbusListener = with pkgs; substituteAll {
    src = ./monitor-input-listener.sh;
    isExecutable = true;
    inherit bash monitorInputSwitcher dbusDestination dbusPath dbusInterface;
  };

  kwinPluginPath = ".local/share/kwin/scripts/MonitorInputSwitcher";
in
{
  boot.kernelModules = [ "i2c-dev" ];
  services.udev.extraRules = ''KERNEL=="i2c-[0-9]*", GROUP+="users"'';

  home-manager.users.faupi = {
    home.file."KDE MonitorInputSwitcher autostart" = fop-utils.makeAutostartItemLink pkgs
      {
        name = "monitor-input-switcher";
        desktopName = "MonitorInputSwitcher";
        exec = dbusListener;
        extraConfig = {
          OnlyShowIn = "KDE";
        };
      }
      {
        systemWide = false;
      };

    # TODO: Switch to `file.recursive = true;` if substituteAll works on directories
    home.file."KDE MonitorInputSwitcher main.js" = {
      target = "${kwinPluginPath}/contents/code/main.js";
      source = with pkgs; substituteAll {
        src = ./kwin-plugin/contents/code/main.js;
        inherit dbusDestination dbusPath dbusInterface;
      };
    };
    home.file."KDE MonitorInputSwitcher metadata" = {
      target = "${kwinPluginPath}/metadata.json";
      source = ./kwin-plugin/metadata.json;
    };
  };
}
