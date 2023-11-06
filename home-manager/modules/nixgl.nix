{ lib, pkgs, ... }:
{
  options = {
    nixGLPackage = lib.mkOption {
      type = lib.types.enum [ "intel" "auto" ];
      default = null;
      visible = false;
      description = ''
        Will be used in commands which require working OpenGL.

        Needed on non-NixOS systems.
      '';
      apply = input:
        (if input == "intel" then
          pkgs.nixgl.nixGLIntel
        else if input == "auto" then
          pkgs.nixgl.auto.nixGLDefault
        else
          null);
    };
  };
}
