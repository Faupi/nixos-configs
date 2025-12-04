{
  inputs = {
    # Base
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-bleeding.url = "github:NixOS/nixpkgs/master";
    nixpkgs-go-kernel.url = "github:NixOS/nixpkgs/0010ca6d14dfe295d7e30aa5751d781d64f3e2cb";
    nur.url = "github:nix-community/NUR";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Steamdeck wrappers
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixgl.url = "github:guibou/nixGL";

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Bleeding edge packages with caches (e.g. Jovian Deck kernel)
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    lsfg-vk = {
      url = "github:pabloaul/lsfg-vk-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";

    suyu.url = "github:suyu-emu/nix-flake";

    kwin-effects-forceblur = {
      url = "github:taj-ny/kwin-effects-forceblur/fea9f80f27389aa8a62befb5babf40b28fed328d"; # Plasma pre-6.4
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = args: import ./flake-outputs.nix args;
}
