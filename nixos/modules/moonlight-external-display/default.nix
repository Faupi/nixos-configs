# TODO: Rework the whole fuckin module - button brokey so it's hacky

{ pkgs, lib, ... }:
let
  ddcutil = ''${lib.getExe pkgs.ddcutil} --model=24G1WG4''; # Targeted to external monitor
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
in
{
  boot.kernelModules = [ "i2c-dev" ];
  services.udev.extraRules = ''KERNEL=="i2c-[0-9]*", GROUP+="users"'';

  home-manager.users.faupi = {
    systemd.user.services = {
      monitor-input-switcher = {
        Unit = {
          Description = "Dbus listener for automatic monitor input switcher for kwin";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          ExecStart = dbusListener;
        };
      };
    };

    xdg.dataFile =
      let
        kwinPluginPath = "kwin/scripts/MonitorInputSwitcher";
      in
      {
        "KDE MonitorInputSwitcher main.js" = {
          target = "${kwinPluginPath}/contents/code/main.js";
          source = with pkgs; substituteAll {
            src = ./kwin-plugin/contents/code/main.js;
            inherit dbusDestination dbusPath dbusInterface;
          };
        };
        "KDE MonitorInputSwitcher metadata" = {
          target = "${kwinPluginPath}/metadata.json";
          source = ./kwin-plugin/metadata.json;
        };
      };
  };
}
