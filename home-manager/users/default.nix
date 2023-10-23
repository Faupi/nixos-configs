{ lib, fop-utils, homeManagerModules, inputs, ... }@flakeArgs:
let
  sharedConfigs = (import ./shared { inherit lib; });

  mkUser = name:
    { extraModules ? [ ] }: {
      "${name}" = { config, lib, pkgs, ... }@homeArgs:
        let
          fullArgs = homeArgs // flakeArgs;
          modulesWithBase = [ sharedConfigs.base ] ++ extraModules;
          wrappedModules = builtins.map (mod: (mod fullArgs)) modulesWithBase;
          userModule = import ./${name}.nix fullArgs;
        in {
          imports = wrappedModules ++ [ userModule ];
          home = lib.mkDefault {
            username = name;
            homeDirectory = "/home/${name}";
            stateVersion = "23.05";
          };
        };
    };
in (fop-utils.recursiveMerge [

  (mkUser "faupi" {
    extraModules = [
      inputs.plasma-manager.homeManagerModules.plasma-manager
      homeManagerModules.desktop-plasma
      homeManagerModules._1password

      sharedConfigs.vscodium

    ];
  })

  (mkUser "masp" {
    extraModules = [
      inputs.plasma-manager.homeManagerModules.plasma-manager
      homeManagerModules.desktop-plasma
      homeManagerModules._1password

      sharedConfigs.syncDesktopItems
      sharedConfigs.vscodium

    ];
  })

])
