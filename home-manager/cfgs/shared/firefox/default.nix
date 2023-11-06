{ pkgs, lib, fop-utils, ... }@args:
with lib; {
  programs.firefox = {
    enable = true;
    package = mkDefault (fop-utils.nixGLWrap
      (pkgs.firefox-wayland.override {
        cfg.enablePlasmaBrowserIntegration = true;
      })
      args);

    profiles = {
      # TODO: Add a module option to extend profiles with `enable`, set IDs automatically
      faupi = (import ./profiles/faupi.nix args) // { id = 0; };
      masp = (import ./profiles/masp.nix args) // { id = 1; };
    };
  };
}
