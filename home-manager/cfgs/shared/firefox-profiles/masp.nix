{ pkgs, fop-utils, ... }@args:
fop-utils.recursiveMerge [
  (import ./base.nix args)
  {
    extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
      temporary-containers
    ];
  }
]
