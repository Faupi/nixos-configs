{ pkgs, config, lib, ... }:
with lib;
{
  options = {
    graphical = mkOption {
      type = types.bool;
      description = "Whether this user has a graphical environment";
      default = false;
    };
  };

  config = mkIf config.graphical
    {
      home.packages = with pkgs; [
        qpwgraph
        (config.lib.nixgl.wrapPackage filelight)
        (config.lib.nixgl.wrapPackage krita)
      ];
    };
}
