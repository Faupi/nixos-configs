{ inputs, lib, ... }:

let
  channels = {
    nixpkgs = inputs.nixpkgs;
    unstable = inputs.nixpkgs-unstable;
    bleeding = inputs.nixpkgs-bleeding;
  };

  allowUnfree = true;

  channelNixPath = lib.mapAttrsToList
    (name: input: "${name}=${toString input}")
    channels;

  channelRegistry = lib.mapAttrs
    (_: input: { flake = input; })
    channels;

  overlayEntries = lib.concatStringsSep "\n"
    (lib.mapAttrsToList
      (name: input: ''
        ${builtins.toJSON name} = import ${toString input} {
          inherit (prev) system;
          config.allowUnfree = ${if allowUnfree then "true" else "false"};
        };
      '')
      channels);

in
{
  nix = {
    nixPath = channelNixPath ++ [
      "nixpkgs-overlays=/etc/nixpkgs/overlays"
    ];

    registry = channelRegistry;
  };

  environment.etc."nixpkgs/overlays/flake-channels.nix".text = ''
    final: prev: {
      ${overlayEntries}
    }
  '';
}
