{ pkgs, fop-utils, ... }:
{
  config.lib.fop-utils = {
    # Creates an autostart desktop entry for the current user
    # See https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/make-desktopitem/default.nix for arguments
    # Shitty workaround but for the checks it's worth it™
    makeAutostartItemLink = { name, ... }@args:
      let
        renderedArgs = args // {
          # Add a 5 second delay because of task icon resolution loading problems on KDE
          exec = ''sh -c "sleep 5 && ${args.exec}"'';
          noDisplay = true;
        };
      in
      {
        source = fop-utils.makeDirectDesktopItem pkgs renderedArgs;
        target = ".config/autostart/${name}.desktop";
      };
  };
}
