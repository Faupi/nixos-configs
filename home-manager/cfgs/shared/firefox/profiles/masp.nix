{ pkgs, fop-utils, ... }@args:
fop-utils.recursiveMerge [
  (import ./base.nix args)
  {
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      onepassword-password-manager
      temporary-containers
      pkgs.two-finger-history-jump
    ];
  }
]
