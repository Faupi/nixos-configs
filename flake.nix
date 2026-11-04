{
  inputs = {
    #region Flake 
    flake-utils.url = "github:numtide/flake-utils";

    # Database for available programs for flake-based systems (command-not-found compat)
    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #!region

    #region Core 
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nixpkgs-bleeding.url = "github:NixOS/nixpkgs/master";
    nur.url = "github:nix-community/NUR";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #!region


    #region Desktop environment 
    nixgl.url = "github:guibou/nixGL";

    dms = {
      url = "github:duxlabs-dev/dux-shell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:duxlabs-dev/dux-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    #!region

    #region Applications 
    blender.url = "github:edolstra/nix-warez?dir=blender";

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake/458cd16116c362a5e92d5db6bdc3599e4e8b1f4a"; # TODO: Unpin once https://github.com/youwen5/zen-browser-flake/issues/24 is resolved
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    #!region

    #region Gaming 
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    playit.url = "github:pedorich-n/playit-nixos-module";

    # Bleeding edge packages with caches (e.g. Jovian Deck kernel)
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Steamdeck components
    jovian = {
      url = "github:Faupi/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Steam plugin+theme loader
    millennium-source = {
      url = "github:SteamClientHomebrew/Millennium/v3.6.2";
      flake = false;
    };
    millennium = {
      url = "github:SteamClientHomebrew/Millennium/v3.6.2?dir=packages/nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        millennium-src.follows = "millennium-source";
      };
    };

    # Utility for managing WiVRn sessions with hooks
    wivrn-connection-manager = {
      url = "github:Kirottu/wivrn-connection-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #!region
  };

  outputs = args: import ./flake-outputs.nix args;
}
