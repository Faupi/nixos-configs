{ config, lib, pkgs, fop-utils, homeManagerModules, inputs, ... }:
with lib;
let
  cfg = config.jovian.decky-loader;
  jsonFormat = pkgs.formats.json { };
in
{
  options.jovian.decky-loader =
    let
      pluginOpt = { ... }: {
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

      themeOpt = { ... }: {
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

      mutableThemeConfigs = mkEnableOption "Mutability of theme configs, requires CSS Loader patch!";
      themes = mkOption {
        description = "CSS Loader themes to install";
        type = with types; attrsOf (submodule themeOpt);
        default = { };
      };
    };

  config =
    let
      user = config.jovian.decky-loader.user;
    in
    {
      # Make sure the home and stateDir paths are matching
      assertions = [
        {
          assertion = (config.jovian.decky-loader.stateDir == config.users.users.${user}.home);
          message = "Decky home directory must be the same as its state directory!";
        }
      ];

      home-manager.users.${user} = {
        imports = [ homeManagerModules.mutability ];

        xdg.userDirs.createDirectories = false;
        home = {
          stateVersion = config.system.stateVersion;

          # Create directories on our own, otherwise they SOMETIMES have root owner for unexplainable reasons.
          # REVIEW if there's a way to tell and go about it.
          activation.ensureDirs = inputs.home-manager.lib.hm.dag.entryBefore [ "linkGeneration" ] ''
            mkdir -p -m 0700 "$HOME/plugins" "$HOME/themes" "$HOME/settings"
          '';

          file =
            (flip mapAttrs cfg.plugins (name: plugin: {
              source = plugin.src;
              target = "plugins/${name}";
            }))
            //
            (lib.lists.foldr (prev: next: prev // next) { } (flip mapAttrsToList cfg.themes (name: theme:
              let
                mergedConfig = (theme.config or { }) // { active = theme.enable; };
                escapedName = builtins.replaceStrings [ " " ] [ "_" ] name;
                configFile = pkgs.writeText "decky-cfg-${escapedName}.json" (builtins.toJSON mergedConfig);
                # TODO: Figure out if the immutability is even needed at this point
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
                # Theme
                ${escapedName} = {
                  source = fop-utils.mkIfElse cfg.mutableThemeConfigs theme.src sourceWithConfig;
                  target = "themes/${name}";
                };

                # Config
                "${escapedName}-config" = mkIf cfg.mutableThemeConfigs {
                  source = configFile;
                  target = "settings/SDH-CssLoader/themes/${name}/config_USER.json";
                  mutable = true;
                  force = true;
                };
              }
            )));
        };
      };
    };
}
