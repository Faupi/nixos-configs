{ config, pkgs, lib, ... }:
with lib;
let 
  host-config = config;
  cfg = config.my.vintagestory;

  modsRepo = pkgs.fetchFromGitHub {
    owner = "Faupi";
    repo = "VintageStoryMods";
    rev = "a050d3d35e4d307bc02d1da88e367fbf4763d3e5";
    sha256 = "159yamr16q8ja972w2s2rqid6cq49vdnawsix1hk3n0n8q1868jx";
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
    (mkIf cfg.client.enable (mkMerge [
      {
        home-manager.users."${cfg.client.user}" = {
          home.packages = [
            (if cfg.mods.enable then (modWrapper cfg.client.package "vintagestory") else cfg.client.package)
          ];
        };
      }

      (mkIf cfg.mods.enable {
        # Link up mod configurations
        system.activationScripts.linkClientModConfigs = ''
          ${pkgs.coreutils-full}/bin/cp -r '${modsRepo}/ModConfig/' '${config.home-manager.users."${cfg.client.user}".home.homeDirectory}/.config/VintagestoryData/ModConfig/'
        '';
      })
    ]))

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
            in ''
              ${core}/bin/mkdir -p '${cfg.server.dataPath}'
              ${core}/bin/ln -sf '${serverConfig}' '${cfg.server.dataPath}/serverconfig.json'
              ${core}/bin/cp -r '${modsRepo}/ModConfig/' '${cfg.server.dataPath}/ModConfig/'
            '';

            environment.etc."resolv.conf".text = "nameserver 8.8.8.8";

            system.stateVersion = "23.05";
          }
        ];
      };
    })

  ];
}
