# Faupi's personal Nix flake

Personal setup for my NixOS and home-manager machines. It is opinionated, a bit messy, and tuned for my own workflows, but everything here is free to use. If you want to upstream anything, go for it; I am slow with PRs.

I try to keep sources attributed in comments, but if anything is missing or questionable I can remove or rework it.

## What this flake provides

- NixOS host configurations built from a shared base and host-specific modules
- Home-manager user configurations with a base + toggleable graphical configuration
- A set of overlays (default flake package set, shared extras, NUR)
- Custom packages in `pkgs/`
- Helper functions and wrappers used across modules

## Layout

- `flake.nix`: inputs only; outputs live in `flake-outputs.nix`, for logical separation
- `flake-outputs.nix`: exposes the various flake outputs - see below
- `nixos/`
  - `cfgs/`: base + per-host configurations
    - `shared/`: shared configuration modules
  - `modules/`: reusable NixOS modules
- `home-manager/`
  - `cfgs/`: base + per-user configurations
    - `shared/`: shared configuration modules
  - `modules/`: reusable home-manager modules
- `pkgs/`: custom packages and overrides used by the overlays
- `overlays.nix`, `utils.nix`, `flake-utils.nix`: helpers and wiring

## Outputs

- `overlays`
  - `default`: this repo’s `pkgs/`
  - `shared`: extra overlays and pinned package sets (stable/unstable/bleeding)
  - `nur`: NUR packages
- `homeUsers`: `faupi`, `masp`
- `homeConfigurations`: `masp`
- `nixosConfigurations`
  - `homeserver`: headless server (build host + cache)
  - `deck`: (deprecated) Steam Deck handheld gaming PC
  - `go`: Lenovo Legion Go handheld gaming PC
  - `LT-masp`: workstation
  - `sandbox`: scratch/test system
- `legacyPackages`
  - x86_64-linux package set from `pkgs/` (for easy `nix build`/`nix shell`)

## Notes

- Some NixOS hosts depend on `sops-nix` secrets; without the encrypted files + my keys, those builds will fail. Use this repo as reference, not a drop-in flake.
- Shared NixOS configs are applied by default in `mkSystem`, with host-specific extras layered on top.
- Home configs are split into base + graphical to keep headless machines clean.

## LLM disclosure

This README was written with LLM help, and I sometimes use them for configuration changes in areas I don’t fully understand yet. This flake powers my primary OS across most of my machines and is an ongoing project, so please expect occasional rough edges.
