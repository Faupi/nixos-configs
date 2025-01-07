{ config, lib, pkgs, inputs, ... }:
with lib;
let
  configPath = ".zen";
  modulePath = [ "programs" "zen-browser" ];
  cfg = getAttrFromPath modulePath config;

  mkFirefoxModule = import "${inputs.home-manager-unstable.outPath}/modules/programs/firefox/mkFirefoxModule.nix";

  # Dookie way of patching the profiles.ini file
  # Basically Zen gets upset it can't write the default avatar path into the profile INI, so it thinks it can't load it and shits the bed
  profiles = flip mapAttrs' cfg.profiles
    (_: profile:
      nameValuePair "Profile${toString profile.id}" {
        Name = profile.name;
        Path = profile.path;
        IsRelative = 1;
        Default = if profile.isDefault then 1 else 0;
        ZenAvatarPath = "chrome://browser/content/zen-avatars/avatar-17.svg"; # Default path for now
      }) // {
    General = {
      StartWithLastProfile = 1;
    } // lib.optionalAttrs (cfg.profileVersion != null) {
      Version = cfg.profileVersion;
    };
  };
  profilesIni = generators.toINI { } profiles;

  # NOTE: Gets nested under "policies" object
  policies = {
    "DisableAppUpdate" = true;
    "ManualAppUpdateOnly" = true;
  };

  _zenPackage = pkgs.BROWSERS.zen-browser.specific;
  zenPackage = pkgs.symlinkJoin {
    name = "zen-browser-custom";
    inherit (_zenPackage) pname version meta;
    paths = [ _zenPackage ];
    postBuild = ''
      mkdir -p "$out/distribution"
      cp "${builtins.toFile "policies.json" (builtins.toJSON {inherit policies;})}" "$out/distribution/policies.json"
    '';
  };
in
{
  imports = [
    (mkFirefoxModule {
      inherit modulePath;
      name = "ZenBrowser";
      wrappedPackageName = "zen";
      unwrappedPackageName = null;
      platforms.linux.configPath = configPath;
    })
  ];

  config = {
    # Workaround for package stuff with HM
    programs.zen-browser.package = mkForce null; # Don't let HM call override on it, there is none
    home.packages = [
      (config.lib.nixgl.wrapPackage  # WebGL compatibility
        zenPackage)
    ];

    # Workaround for profiles INI making profiles unloadable
    home.file."${cfg.configPath}/profiles.ini" = mkForce (mkIf (cfg.profiles != { }) { text = profilesIni; });
  };
}
