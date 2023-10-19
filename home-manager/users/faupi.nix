{ lib, pkgs, fop-utils, homeManagerModules, ... }@args:
(fop-utils.recursiveMerge [
  # TODO: This is just awful
  (import ./shared/base.nix args)
  (import ./shared/vscodium.nix args)
  {
    imports = [ homeManagerModules._1password ];

    programs = {
      _1password = {
        enable = true;
        autostart = {
          enable = true;
          silent = true;
        };
        useSSHAgent = true;
      };

      git = {
        userName = "Faupi";
        userEmail = "matej.sp583@gmail.com";
      };
    };

    services = {
      kdeconnect = {
        # TODO: Open firewall TCP+UDP 1714-1764
        enable = true;
        indicator = true;
      };
    };
  }
])
