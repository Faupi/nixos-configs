{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.jovian.decky-loader;
  jsonFormat = pkgs.formats.json { };
in
{
  options.jovian.decky-loader =
    let
      pluginOpt = { name, ... }: {
        options = {
          src = mkOption {
            type = types.path;
          };
          # TODO: Add config
          # config = mkOption {
          #   description = "Configuration of plugin, normally in JSON";
          #   type = jsonFormat.type;
          #   default = null;
          # };
        };
      };

      themeOpt = { name, ... }: {
        options = {
          enable = mkEnableOption "Enable theme by default";
          src = mkOption {
            type = types.path;
          };
          config = mkOption {
            description = "Configuration of the theme, normally in JSON";
            type = jsonFormat.type;
            default = null;
          };
        };
      };
    in
    {
      plugins = mkOption {
        description = "Plugins to install";
        type = with types; attrsOf (submodule pluginOpt);
        default = { };
      };

      themes = mkOption {
        description = "CSS Loader themes to install";
        type = with types; attrsOf (submodule themeOpt);
        default = { };
      };
    };

  config =
    let
      dataPath = config.jovian.decky-loader.stateDir;
      pluginPath = "${dataPath}/plugins";
      themesPath = "${dataPath}/themes";
    in
    {
      # TODO: This could probably be rewritten properly with out of store links, but I'm too fucking tired to figure it out right now. Too bad!
      system.activationScripts.installDeckyPlugins = ''
        # SETUP
        mkdir -p "${pluginPath}" "${themesPath}"

        # PLUGINS
        ${
          pkgs.lib.concatStringsSep "\n" (flip mapAttrsToList cfg.plugins (
            name: plugin: 
            ''
              ln -snf "${plugin.src}" "${pluginPath}/${name}"
            ''
          ))
        }

        # THEMES
        ${
          pkgs.lib.concatStringsSep "\n" (flip mapAttrsToList cfg.themes (
            name: theme: 
            let
              path = "${themesPath}/${name}";
              mergedConfig = theme.config // { active = theme.enable; };
              configFile = jsonFormat.generate "decky-cfg-${name}.json" mergedConfig;
            in
            ''
              cp -Tarf "${theme.src}" "${path}"
            '' 
            + (strings.optionalString (theme.config != null) ''
              cp -Taf "${configFile}" "${path}/config_USER.json"
            '')
          ))
        }
      '';
    };
}
