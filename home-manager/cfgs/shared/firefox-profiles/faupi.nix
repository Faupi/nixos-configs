{ pkgs, fop-utils, ... }@args:
fop-utils.recursiveMerge [
  (import ./base.nix args)
  {
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      ublock-origin
      sponsorblock # TODO: Link ID thru sops
      istilldontcareaboutcookies # Automatic cookie denial
      onepassword-password-manager

      enhancer-for-youtube # Fuck the new layout changes seriously
      protondb-for-steam
      steam-database
    ];
  }
]
