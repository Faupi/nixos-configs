{ pkgs, config, lib, ... }@args:
with lib; {
  programs.firefox = {
    enable = true;
    package = mkDefault (
      config.lib.nixgl.wrapPackage  # WebGL compatibility
        (pkgs.firefox-wayland.override
          {
            cfg.enablePlasmaBrowserIntegration = true;
          })
    );

    profiles = {
      # TODO: Add a module option to extend profiles with `enable`, set IDs automatically
      faupi = (import ./profiles/faupi.nix args) // { id = 0; };
      masp = (import ./profiles/masp.nix args) // { id = 1; };
    };
  };
}
