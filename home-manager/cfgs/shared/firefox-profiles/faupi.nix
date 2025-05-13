{ pkgs, fop-utils, ... }@args:
fop-utils.recursiveMerge [
  (import ./base.nix args)
  {
    extensions.packages = (with pkgs.nur.repos.rycee.firefox-addons; [
      consent-o-matic # Automatically decline cookies

      enhancer-for-youtube # Fuck the new layout changes seriously
      sponsorblock # TODO: Link ID thru sops

      protondb-for-steam
      steam-database

      refined-github
      lovely-forks # Shows notable forks on GitHub
    ]) ++ (with pkgs.nur.repos.bandithedoge.firefoxAddons; [
      material-icons-for-github
    ]);
  }
]
