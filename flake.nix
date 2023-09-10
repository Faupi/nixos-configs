{
  nixConfig = {
    accept-flake-config = true;
    extra-substituters = [
      "https://veloren-nix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "veloren-nix.cachix.org-1:zokfKJqVsNV6kI/oJdLF6TYBdNPYGSb+diMVQPn/5Rc="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Steamdeck wrapper
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    
    flake-utils.url = "github:numtide/flake-utils";

    # Wine applications
    erosanix = {
      url = "github:emmanuelrosa/erosanix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Discord-screenaudio | TODO: Use official package once merged
    discord-screenaudio-flake.url = "github:huantianad/nixpkgs/discord-screenaudio";

    veloren.url = "gitlab:veloren/veloren";
  };

  outputs = { 
    self, 
    nixpkgs, 
    unstable, 
    flake-utils, 
    home-manager, 
    jovian, 
    plasma-manager, 
    erosanix, 
    discord-screenaudio-flake, 
    veloren,
    ... 
  }@inputs: 
  with flake-utils.lib; 
  let
    lib = nixpkgs.lib;
  in
  rec {
    # TODO: Set up a builder for configurations when more are added (include base and home-manager by default, etc.)
    #       - Going to be more important when overlays come into play (Jovian!)
    #       - Forward arguments to @inputs and let systems inherit it automatically
    
    # Use the default overlay to export all packages under ./pkgs
    overlays = {
      default = final: prev:
        (import ./pkgs {
          inherit (prev) lib;
          pkgs = prev;
        })
        # Custom overlays (sorry whoever has to witness this terribleness)
        // {
          discord-screenaudio = discord-screenaudio-flake.legacyPackages.${prev.system}.discord-screenaudio;

          ferdium-wayland = unstable.legacyPackages.${prev.system}.ferdium.overrideAttrs (prevAttrs: rec {
            nativeBuildInputs = (prevAttrs.nativeBuildInputs or []) ++ [ unstable.legacyPackages.${prev.system}.makeBinaryWrapper ];
            postInstall = (prevAttrs.postInstall or "") + ''
              wrapProgram $out/bin/ferdium --set QT_QPA_PLATFORM=wayland --set NIXOS_OZONE_WL="1" --add-flags "--ozone-platform=wayland" --add-flags "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,WaylandWindowDecorations"
            '';
            # QT_QPA_PLATFORM=wayland NIXOS_OZONE_WL="1" ferdium --ozone-platform=wayland --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,WaylandWindowDecorations
          });

          vscodium-fhs-nogpu = prev.symlinkJoin {
            name = prev.vscodium-fhs.name;
            pname = prev.vscodium-fhs.pname;
            version = prev.vscodium-fhs.version;
            
            paths = 
            let
              vscodium-fhs-wrapped-nogpu = prev.writeShellScriptBin "codium" ''
                exec ${prev.vscodium-fhs}/bin/codium --disable-gpu
              '';
            in [
              vscodium-fhs-wrapped-nogpu
              prev.vscodium-fhs
            ];
          };

          veloren-server-cli = veloren.packages.${prev.system}.veloren-server-cli;
        };
    };

    # Export modules under ./modules as NixOS modules
    nixosModules = (import ./modules { inherit lib; });

    nixosConfigurations = {
      homeserver = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./cfgs/base
          ./cfgs/homeserver { nixpkgs.overlays = [ self.overlays.default ]; }  # TODO: clean up somehow
          nixosModules.octoprint
        ];
      };

      deck = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          home-manager.nixosModules.home-manager
          "${jovian}/modules"
          ./cfgs/base
          ./cfgs/deck { nixpkgs.overlays = [ self.overlays.default ]; }  # TODO: clean up somehow
          nixosModules.desktop-plasma
          nixosModules.steamdeck
          nixosModules.firefox
          nixosModules._1password
          nixosModules.easyeffects
        ];
        specialArgs = { inherit plasma-manager erosanix; };
      };

      sandbox = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          home-manager.nixosModules.home-manager
          ./cfgs/base
          ./cfgs/sandbox { nixpkgs.overlays = [ self.overlays.default ]; }  # TODO: clean up somehow
          nixosModules.desktop-plasma
          nixosModules.firefox
        ];
        specialArgs = { inherit plasma-manager; };
      };
    };
  } 
  // eachSystem [ system.x86_64-linux ] (system:
    let 
      pkgs = nixpkgs.legacyPackages.${system}; 
    in
    {
      # Other than overlay, we have packages independently declared in flake.
      packages = (import ./pkgs {
        inherit lib;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      });
    }
  );
}
