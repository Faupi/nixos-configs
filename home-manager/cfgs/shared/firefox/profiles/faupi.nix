{ pkgs, fop-utils, ... }@args:
fop-utils.recursiveMerge [
  (import ./base.nix args)
  {
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      sponsorblock # TODO: Link ID thru sops
      onepassword-password-manager
      youtube-shorts-block
      protondb-for-steam
      steam-database
    ];
  }
]