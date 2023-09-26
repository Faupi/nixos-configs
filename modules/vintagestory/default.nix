{ config, pkgs, lib, ... }:
with lib;
let 
  host-config = config;
  cfg = config.my.vintagestory;

  modsRepo = pkgs.fetchFromGitHub {
    owner = "Faupi";
    repo = "VintageStoryMods";
    rev = "0e60fcf8575f89d32bce0ec177b8ecc117c9187d";
    sha256 = "0ap7a4z7ha99nwxp05bmsjbnmf4nlqbsilhp1md1kbyl5gy0l93a";
  };
  modWrapper = package: binary: (pkgs.symlinkJoin {
    name = "${package.name}-modded";
    paths = 
    let
      modded-package = pkgs.writeShellScriptBin binary ''
        exec ${package}/bin/${binary} --addModPath "${modsRepo}/Mods" "$@"
      '';
    in [
      modded-package
      package
    ];
  });
in
{
  options.my.vintagestory = {
    client = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      package = mkOption {
        type = types.package;
        default = pkgs.vintagestory;
      };
      user = mkOption {
        type = types.str;
      };
    };
    server = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      package = mkOption {
        type = types.package;
        default = pkgs.vintagestory;
      };
      dataPath = mkOption {
        type = types.str;
        default = "/srv/vintagestory-server";
      };
    };
    mods = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkMerge [

    # Client
    (mkIf cfg.client.enable {
      home-manager.users."${cfg.client.user}" = {
        home.packages = [
          (if cfg.mods.enable then (modWrapper cfg.client.package "vintagestory") else cfg.client.package)
        ];
      };

      # Link up mod configurations
      system.activationScripts.linkClientModConfigs = 
      let 
        rsync = pkgs.rsync;

        modConfigDir = ./ModConfig;
      in ''
        ${rsync}/bin/rsync -r "${modConfigDir}/" "/home/${cfg.client.user}/.config/VintagestoryData/ModConfig/"
      '';
    })

    # Server
    (mkIf cfg.server.enable {

      networking.firewall = {
        allowedTCPPorts = [ 42420 ];
      };

      containers.vintagestory-server = {
        autoStart = true;
        privateNetwork = false;
        forwardPorts = [
          {
            containerPort = 42420;
            hostPort = 42420;
            protocol = "tcp";
          }
        ];
        extraFlags = [ "-U" ];  # Security

        config = { config, pkgs, ... }:
        let
          serverPackage = if cfg.mods.enable then (modWrapper cfg.server.package "vintagestory-server") else cfg.server.package;
          serverConfig = builtins.toFile "serverconfig.json" (builtins.toJSON (import ./serverconfig.nix { inherit (cfg.server) dataPath; }));
        in
        mkMerge [
          {
            # Inherit overlays
            nixpkgs.overlays = host-config.nixpkgs.overlays;

            networking.firewall = {
              enable = true;
              allowedTCPPorts = [ 42420 ];
            };
            
            # Service
            systemd.services.vintagestory-server = {
              enable = true;
              description = "Vintage story server";
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              serviceConfig = {
                Restart = "always";
                RestartSec = 30;
                StandardOutput = "syslog";
                StandardError = "syslog";
                SyslogIdentifier = "VSSRV";
                ExecStart = "${serverPackage}/bin/vintagestory-server --dataPath '${cfg.server.dataPath}'";
                WorkingDirectory = cfg.server.dataPath;
              };
            };

            # Link up server data
            system.activationScripts.linkServerData = 
            let 
              core = pkgs.coreutils-full;
              rsync = pkgs.rsync;

              modConfigDir = ./ModConfig;
            in ''
              ${core}/bin/mkdir -p '${cfg.server.dataPath}'
              ${core}/bin/ln -sf '${serverConfig}' '${cfg.server.dataPath}/serverconfig.json'
              ${rsync}/bin/rsync -r '${modConfigDir}/' '${cfg.server.dataPath}/ModConfig/'
            '';

            environment.etc."resolv.conf".text = "nameserver 8.8.8.8";

            system.stateVersion = "23.05";
          }
        ];
      };
    })

  ];
}
