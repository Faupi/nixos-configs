{ config, lib, pkgs, inputs, ... }:
let
  inherit (lib) mkDefault mkForce mkIf getAttrFromPath flip mapAttrs' nameValuePair generators;

  configPath = ".zen";
  modulePath = [ "programs" "zen-browser" ];
  cfg = getAttrFromPath modulePath config;

  mkFirefoxModule = import "${inputs.home-manager.outPath}/modules/programs/firefox/mkFirefoxModule.nix";

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
      })
  // {
    General = {
      StartWithLastProfile = 1;
    } // lib.optionalAttrs (cfg.profileVersion != null) {
      Version = cfg.profileVersion;
    };

    # Flatpak, no idea if this ID holds
    Install2953CB39A2589173 = {
      # Prefill the first profile
      Default = (lib.findFirst (profile: profile.isDefault) null (builtins.attrValues cfg.profiles)).path;
    };
  };
  profilesIni = generators.toINI { } profiles;

  zenPackage = pkgs.zen-browser;
in
{
  imports = [
    (mkFirefoxModule {
      inherit modulePath;
      name = "ZenBrowser";
      wrappedPackageName = "zen";
      unwrappedPackageName = null;
      platforms = {
        linux.configPath = configPath;
        darwin = { }; # nechce se mi
      };
    })
  ];

  config = {
    programs.zen-browser.package = mkDefault (config.lib.nixgl.wrapPackage zenPackage);

    # Workaround for profiles INI making profiles unloadable
    home.file."${cfg.configPath}/profiles.ini" = mkForce (mkIf (cfg.profiles != { }) {
      text = profilesIni;

      # Flatpak Zen will always try to do a per-installation update! Mostly just linking the default to the one install.
      mutable = true;
      force = true;
    });
  };
}
