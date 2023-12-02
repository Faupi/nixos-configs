{ pkgs, config, lib, ... }@args:
with lib; {
  programs.firefox = {
    enable = true;
    package = mkDefault (
      config.lib.nixgl.wrapPackage  # WebGL compatibility
        (pkgs.firefox-wayland.override
          {
            # TODO: Enable when shit is fixed (takes nativeMessagingHosts directly instead of the packages for building)
            # nativeMessagingHosts.packages = [
            #   pkgs.libsForQt5.plasma-browser-integration
            # ];
          })
    );

    profiles = {
      # TODO: Add a module option to extend profiles with `enable`, set IDs automatically
      faupi = (import ./profiles/faupi.nix args) // { id = 0; };
      masp = (import ./profiles/masp.nix args) // { id = 1; };
    };
  };
}
