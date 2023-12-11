{ pkgs, ... }:
{
  config.lib.fop-utils = {
    # Creates an autostart desktop entry for the current user
    # See https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/make-desktopitem/default.nix for arguments
    # Shitty workaround but for the checks it's worth it™
    makeAutostartItem = { name, ... }@args:
      {
        source = "${pkgs.makeDesktopItem args}/share/applications/${name}.desktop";
        target = ".config/autostart/${name}.desktop";
      };
  };
}
