{ pkgs, ... }:
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
    systemd.user.services."monitor-input-switcher" = {
      Unit.Description = "DBus message listener for MonitorInputSwitcher";
      Service.ExecStart = dbusListener;
      Install.WantedBy = [ "default.target" ];
    };

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
