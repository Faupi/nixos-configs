{ config, lib, pkgs, fop-utils, ... }@args:
with lib;
(import ./base.nix args) // {
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    onepassword-password-manager
    temporary-containers
  ];
}
