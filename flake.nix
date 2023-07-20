{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    # plasma-manager = builtins.fetchTarball {
    #   url = "https://github.com/pjones/plasma-manager/archive/16c437e43a0e049b15c9bfd37295f6e978ea9955.tar.gz";
    #   sha256 = "sha256:0b03m1f6zixw1z9bz4iac8m8d91ynsm4im5dsjgz1z4xzb6ygsbl";
    # };

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS/8a934c6ebf10d0a153f0b62d933f7946e67f610f";
    };
    # jovian = builtins.fetchTarball {
    #   url = "https://github.com/Jovian-Experiments/Jovian-NixOS/archive/8a934c6ebf10d0a153f0b62d933f7946e67f610f.tar.gz";
    #   sha256 = "sha256:0f06vjsfppjwk4m94ma1wqakfc7fdl206db39n1hsiwp43qz7r7x";
    # };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, jovian }: {
    # TODO: Set up a builder for configurations when more are added (include base and home-manager by default, etc.)
    nixosConfigurations = {
      homeserver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./cfgs/base
          ./cfgs/homeserver
          ./modules/octoprint
        ];
      };

      deck = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          home-manager.nixosModules.home-manager
          plasma-manager.homeManagerModules.plasma-manager
          "${jovian}/modules"
          ./cfgs/base
          ./cfgs/deck
          ./modules/firefox
        ];
      };

      sandbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          home-manager.nixosModules.home-manager
          ./cfgs/base
          ./cfgs/sandbox
          ./modules/firefox
        ];
      };
    };
  };
}
