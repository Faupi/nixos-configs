{ inputs, lib, config, ... }:
{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

  services.flatpak = {
    enable = true;

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    overrides.settings.global = {
      Environment = {
        # Make sure that if data on the user profile is mounted, it can be used
        XDG_DATA_DIRS = lib.makeSearchPath "share" [
          config.home.profileDirectory
          "${config.home.homeDirectory}/.local"
          "/app"
        ];
      };
    };
  };
}
