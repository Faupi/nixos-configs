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
          # TODO: Rename on both plugin and themes to "settings" for unity
          config = mkOption {
            description = "Configuration of the theme, normally in JSON";
            type = jsonFormat.type;
            default = null;
          };
        };
      };
    in
    {
      # TODO: Rework to list of package (path string) or attrsets (src, config, etc)
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
      user = config.jovian.decky-loader.user;
      pluginPath = "plugins";
      themesPath = "themes";
    in
    {
      # Make sure the home and stateDir paths are matching
      assertions = [
        {
          assertion = (config.jovian.decky-loader.stateDir == config.users.users.${user}.home);
          message = "Decky home directory must be the same as its state directory!";
        }
      ];

      home-manager.users.${user}.home = {
        stateVersion = config.system.stateVersion;

        file = (flip mapAttrs cfg.plugins (name: plugin: {
          source = plugin.src;
          target = "${pluginPath}/${name}";
        }))
        // (flip mapAttrs cfg.themes (name: theme:
          let
            escapedName = builtins.replaceStrings [ " " ] [ "_" ] name;
            themePath = "${themesPath}/${name}";
            mergedConfig = (theme.config or { }) // { active = theme.enable; };
            configFile = pkgs.writeText "decky-cfg-${escapedName}.json" (builtins.toJSON mergedConfig);

            # TODO: Maybe remap where CSS loader stores configs for themes (`decky/settings/SDH-CssLoader/themes/<name>`?)
            sourceWithConfig = pkgs.symlinkJoin
              {
                name = "${escapedName}-configured";
                paths = [ theme.src ];
                postBuild = ''
                  ln -sf "${configFile}" "$out/config_USER.json"
                '';
              };
          in
          {
            source = sourceWithConfig;
            target = themePath;
          }));
      };
    };
}
