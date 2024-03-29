{ config, pkgs, lib, fop-utils, ... }:
# TODO: Add KDE desktop item rule (icon)

let
  homeVersion = "5.6";
  configPath = "${config.home.homeDirectory}/.config/cura/${homeVersion}";
  localPath = "${config.home.homeDirectory}/.local/share/cura/${homeVersion}";
  pluginPath = "${localPath}/plugins";
in
fop-utils.recursiveMerge [
  # Base
  {
    home.packages = with pkgs; [
      cura
    ];

    home.activation.cura-base-config =
      let
        configFile = (pkgs.writeText "cura.cfg" (lib.generators.toINI { } {
          general = {
            version = 7; # Config schema version maybe?
            theme = "cura-dark";
            accepted_user_agreement = true;
          };

          # TODO
          cura.active_machine = "Sovol SV06";

          info = {
            automatic_update_check = true;
            automatic_plugin_update_check = true;
          };
        }));
      in
      ''
        ${lib.getExe pkgs.crudini} --merge "${configPath}/cura.cfg" < "${configFile}"
      '';
  }

  # Settings Guide
  {
    home.file."Cura settings guide" =
      let
        version = "2.9.2";
        pluginName = "SettingsGuide2";
        sourceFiles = pkgs.fetchzip {
          url = "https://github.com/Ghostkeeper/SettingsGuide/releases/download/v${version}/SettingsGuide${version}-sdk8.0.0.curapackage";
          sha256 = "sha256-BonnE8zDZpTgPT29zzQmqP6AGrw2RGeWkDA7uvTsxl0=";
          extension = "zip";
          stripRoot = false;
        };
      in
      {
        target = "${pluginPath}/${pluginName}/";
        source = "${sourceFiles}/files/plugins/${pluginName}/";
      };
  }

  # Octoprint
  {
    home.file."Cura Octoprint" =
      let
        version = "3.7.3";
        pluginName = "OctoPrintPlugin";
        sourceFiles = pkgs.fetchzip {
          url = "https://github.com/fieldOfView/Cura-OctoPrintPlugin/releases/download/v${version}/OctoPrintPlugin_v${version}_Cura5.0-current.curapackage";
          sha256 = "sha256-6dgTN7ChQfchvhGxot9AsqCy6PiX2XUphqCZR6TqB8g=";
          extension = "zip";
          stripRoot = false;
        };
      in
      {
        target = "${pluginPath}/${pluginName}/";
        source = "${sourceFiles}/files/plugins/${pluginName}/";
      };

    home.activation.cura-octoprint-config =
      let
        configFile = (pkgs.writeText "cura-octoprint.cfg" (lib.generators.toINI { } {
          octoprint = {
            manual_instances = ''{"Sovol SV06": {"address": "homeserver.local", "port": 5000, "path": "/", "useHttps": false, "userName": "", "password": ""}}'';
          };
        }));
      in
      ''
        ${lib.getExe pkgs.crudini} --merge "${configPath}/cura.cfg" < "${configFile}"
      '';
  }

  # TODO: Add 
  # thumbnails
  # https://marketplace.ultimaker.com/app/cura/plugins/fieldofview/ArcWelderPlugin
  # https://marketplace.ultimaker.com/app/cura/plugins/fieldofview/PrinterSettingsPlugin
  # https://marketplace.ultimaker.com/app/cura/plugins/fieldofview/StartOptimiser
  # https://marketplace.ultimaker.com/app/cura/plugins/fieldofview/MaterialSettingsPlugin
  # https://marketplace.ultimaker.com/app/cura/plugins/5axes/CalibrationShapes
  # https://marketplace.ultimaker.com/app/cura/plugins/5axes/TabAntiWarping
  # https://marketplace.ultimaker.com/app/cura/plugins/molodos/ElegooNeptune3Thumbnails
]
