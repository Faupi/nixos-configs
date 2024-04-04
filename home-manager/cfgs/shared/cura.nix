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

  # Arc Welder
  {
    home.file =
      let
        version = "3.6.0";
        pluginName = "ArcWelderPlugin";
        sourceFiles = pkgs.fetchzip {
          url = "https://github.com/fieldOfView/Cura-ArcWelderPlugin/releases/download/v${version}/ArcWelderPlugin_v${version}_Cura5.0.curapackage";
          sha256 = "sha256-/MBaMa8+Enp3zseZr/aY2GiLux3kRGc3K3X8F893tac=";
          extension = "zip";
          stripRoot = false;
        };
      in
      {
        "Cura arc welder" = {
          target = "${pluginPath}/${pluginName}/";
          source = "${sourceFiles}/files/plugins/";
          recursive = true;
        };
        "Cura arc welder executable binary fix" = {
          target = "${pluginPath}/${pluginName}/bin/linux/ArcWelder";
          source = "${sourceFiles}/files/plugins/${pluginName}/bin/linux/ArcWelder";
          executable = true;
          mutable = true; # Because it REALLY tries to apply the executable flag despite already having it ffs
          force = true; # Needed for mutable
        };
      };
  }

  # Start Optimizer
  {
    home.file."Cura start optimizer" =
      let
        version = "3.6.0";
        pluginName = "StartOptimiser";
        sourceFiles = pkgs.fetchzip {
          url = "https://github.com/fieldOfView/Cura-StartOptimiser/releases/download/v${version}/StartOptimiser_v${version}_Cura5.0.curapackage";
          sha256 = "sha256-Qv58jZvnh9xor+AOZ7tog/1woLziID+bGHEyeXOyx7k=";
          extension = "zip";
          stripRoot = false;
        };
      in
      {
        target = "${pluginPath}/${pluginName}/";
        source = "${sourceFiles}/files/plugins/${pluginName}/";
      };
  }

  # Start Optimizer
  {
    home.file."Cura TabAntiWarping" =
      let
        version = "1.4.0";
        pluginName = "TabAntiWarping";
        sourceFiles = pkgs.fetchzip {
          # NOTE: The URL might fuck up if there's a version change so gl
          url = "https://github.com/5axes/TabAntiWarping/releases/download/V${version}/TabAntiWarping-v${version}-2023-01-19T00_20_49Z.curapackage";
          sha256 = "";
          extension = "zip";
          stripRoot = false;
        };
      in
      {
        target = "${pluginPath}/${pluginName}/";
        source = "${sourceFiles}/files/plugins/${pluginName}/";
      };
  }

  # TODO: Add 
  # https://marketplace.ultimaker.com/app/cura/plugins/fieldofview/PrinterSettingsPlugin
  # https://marketplace.ultimaker.com/app/cura/plugins/fieldofview/MaterialSettingsPlugin
  # https://marketplace.ultimaker.com/app/cura/plugins/5axes/CalibrationShapes
  # https://marketplace.ultimaker.com/app/cura/plugins/molodos/ElegooNeptune3Thumbnails
]
