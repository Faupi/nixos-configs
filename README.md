# Faupi's personal nix flake

Personal setup for my nix(OS) systems with a bunch of random packages and modules for convenience.
**Everything is free to use, if anybody wants to push anything to upstream, that's absolutely fine - I get too distracted to handle official PRs.**

For parts that I've taken from somewhere else, I try to comment them with links, but sometimes I might forget or lose it - I can remove or rework parts that I cannot use.

## Directories:

Directories within the root are by scope:

- `home-manager`: Home-manager (user-scope) related
- `nixos`: Obviously NixOS system
- `pkgs`: Packages used in overlays

`nixos` and `home-manager` then split off into modules and configs:

- Modules having all various options for easier configuration
- Configs include configuration sets for various uses (like the entirety of VSCodium)

## Mappings:

Most things are mapped under `flake-outputs.nix` so I don't have to re-reference the same thing.

I've chosen to separate the home-manager user configurations into their own "output", so they can be used on both NixOS and non-NixOS systems, being freely importable wherever.

Modules are probably self-explainatory, but regarding configs, `flake-outputs.nix` uses mappings:

- `homeUsers` (`home-manager/cfgs`)
  - Defined using `mkHome` - `home-manager/cfgs/<name>`
  - Specific user configurations (mostly, see `homeManagerConfigs` below)
  - Can be imported within NixOS systems or exposed under `homeConfigurations` for home-manager itself
  - Split into 2 parts - base is always non-graphical, graphical extras are imported with an extra argument
    - I'm not proud of this solution, but it lets me use the same configurations on machines with no display outputs without unneeded extras
- `homeManagerConfigs` (`home-manager/cfgs/shared`)
  - Configurations for specific modules/apps, e.g. entirety of VSCodium with extensions and settings
- Base NixOS configuration (`nixos/cfgs/base`)
  - Configuration used on all NixOS machines under the flake
  - Automatically added via `mkSystem`
- NixOS systems under `nixosConfigurations` (`nixos/cfgs`)
  - Defined using `mkSystem` - `nixos/cfgs/<name>`
  - Configurations for strictly NixOS machines - system-wide, hardware

## Footnote

This flake can be a huge mess (especially since I'm really just doing it for myself), but I figured I'd keep it public as I'd love for Nix to keep growing and honestly I don't think I can ever go back to another OS.
