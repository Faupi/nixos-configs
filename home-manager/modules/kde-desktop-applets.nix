{ config, lib, ... }:
with lib;
let
  cfg = config.programs.plasma.desktop-applets;

  appletOpts = { name, config, options, ... }: {
    # TODO: PISS
  };

  containmentOpts = { name, config, options, ... }: {
    options = {
      enable = mkOption {
        default = true;
        type = types.bool;
        description = "Enable containment";
      };
      applets = mkOption {
        default = { };
        type = with types; attrsOf (submodule commandOpts);
      };

      # TODO: SOMEHOW IMPLEMENT THE REST :3
    };
  };
in
{
  options.programs.plasma.desktop-applets = {
    # containments = [containments (with args) -> applets (with args)]
  };

  config = {
    # home.activation.clean-desktop-appletsrc = lib.hm.dag.entryBefore [ "configure-plasma" ] ''
    #   rm '${home.homeDirectory}/.config/plasma-org.kde.plasma.desktop-appletsrc'
    # '';

    programs.plasma.configFile."plasma-org.kde.plasma.desktop-appletsrc" = { };
  };
}
