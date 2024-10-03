{ pkgs, fop-utils, ... }@args:
fop-utils.recursiveMerge [
  (import ./base.nix args)
  {
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      enhancer-for-youtube # Fuck the new layout changes seriously
      protondb-for-steam
      steam-database
    ];
  }
]
