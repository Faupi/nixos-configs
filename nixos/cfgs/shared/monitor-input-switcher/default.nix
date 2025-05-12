# TODO: Rework the whole fuckin module - button brokey so it's hacky

{ config, pkgs, lib, ... }:
let
  cfg = config.flake-configs.monitor-input-switcher;
in
{
  options.flake-configs.monitor-input-switcher = {
    enable = lib.mkEnableOption "Automatic monitor input switcher for kwin";
    user = lib.mkOption {
      type = lib.types.str;
      # TODO: Default to main user of the system when that option is added
    };
  };

  config =
    let
      ddcutil = ''${lib.getExe pkgs.ddcutil} --model=24G1WG4''; # Targeted to external monitor
      dbusDestination = "faupi.MonitorInputSwitcher";
      dbusPath = "/faupi/MonitorInputSwitcher";
      dbusInterface = dbusDestination;

      monitorInputSwitcher = pkgs.writeScriptBin "switch-monitor-input" (builtins.readFile (pkgs.replaceVarsWith {
        src = ./switch-monitor-input.sh;
        isExecutable = true;

        replacements = {
          inherit (pkgs) bash;
          inherit ddcutil;
        };
      }));
      dbusListener = pkgs.replaceVarsWith {
        src = ./monitor-input-listener.sh;
        isExecutable = true;

        replacements = {
          inherit (pkgs) bash;
          inherit dbusDestination dbusPath dbusInterface;
          monitorInputSwitcher = lib.getExe monitorInputSwitcher;
        };
      };
    in
    lib.mkIf (cfg.enable) {
      boot.kernelModules = [ "i2c-dev" ];
      services.udev.extraRules = ''KERNEL=="i2c-[0-9]*", OWNER+="${cfg.user}"'';

      home-manager.users.${cfg.user} = {
        systemd.user.services = {
          monitor-input-switcher = {
            Unit = {
              Description = "Dbus listener for automatic monitor input switcher for kwin";
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = dbusListener;
              Restart = "on-success";
            };
          };
        };

        home.packages = [ monitorInputSwitcher ];

        xdg.dataFile =
          let
            kwinPluginPath = "kwin/scripts/MonitorInputSwitcher";
          in
          {
            "KDE MonitorInputSwitcher main.js" = {
              target = "${kwinPluginPath}/contents/code/main.js";
              source = pkgs.replaceVars ./kwin-plugin/contents/code/main.js {
                inherit dbusDestination dbusPath dbusInterface;
              };
            };
            "KDE MonitorInputSwitcher metadata" = {
              target = "${kwinPluginPath}/metadata.json";
              source = ./kwin-plugin/metadata.json;
            };
          };
      };
    };
}
