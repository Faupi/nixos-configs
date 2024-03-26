{ config, pkgs, lib, ... }:
with lib;
let
  hostConfig = config;
  externalPort = 25575;
  internalPort = externalPort;
  dataDir = "/srv/minecraft";

  version = "unstable-2024-03-26";
  modsRepo = pkgs.fetchFromGitHub {
    owner = "Faupi";
    repo = "MinecraftMods";
    rev = "33b3fb543d260e31822d86cd2ff438ba0868215c";
    sha256 = "173j1mcwd718y5h7mgixasiann2wzwl98cjwi5lxrpycxl8kq2kh";
  };
  modBlacklist = [
    "DistantHorizons"
    # "Terralith" # Disable if flat world
  ];

  # cba to make a proper option for this yet
  opsFile = pkgs.writeText "ops.json"
    (builtins.toJSON
      (mapAttrsToList (n: v: { name = n; uuid = v.uuid; level = v.level; }) {
        Faupi = {
          uuid = "b36aeccb-99b6-4384-b986-a685d39f364b";
          level = 4;
        };
        KudoTheYeen = {
          uuid = "e4b86d34-6a04-404e-bb1a-203cf18881dd";
          level = 4;
        };
      }));

  CFTunnelID = "bed95850-cd5a-4a83-a43f-3ec552d00462";
in
{
  sops.secrets = {
    minecraft-tunnel-test = {
      sopsFile = ./secrets.yaml;
      mode = "0440";
      owner = config.services.cloudflared.user;
      group = config.services.cloudflared.group;
      restartUnits = [ "cloudflared-tunnel-${CFTunnelID}.service" ];
    };
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      ${CFTunnelID} = {
        credentialsFile = config.sops.secrets.minecraft-tunnel-test.path;
        default = "http_status:404";
        ingress = {
          "mc-test.faupi.net" = "tcp://localhost:${toString externalPort}";
        };
      };
    };
  };

  portForwardedContainers.minecraft-server-test = {
    enable = true;
    autoStart = true;
    ports = {
      open = true;
      tcp.${toString externalPort} = internalPort;
      udp.${toString externalPort} = internalPort;
    };

    config = { config, pkgs, ... }: {
      nixpkgs.overlays = hostConfig.nixpkgs.overlays;

      services.minecraft-server = {
        enable = true;
        package = pkgs.minecraft-server-fabric_1_20_4;
        inherit dataDir;
        eula = true;
        openFirewall = true;
        declarative = true;

        serverProperties =
          let
            versionText = "Version: ${strings.getVersion version}";
            versionLinePrefix = "§l  §r";
            versionLinePadded = strings.fixedWidthString (65 - (stringLength versionLinePrefix)) " " versionText; # Would've been 64 but colon generates a slash
            versionLine = versionLinePrefix + versionLinePadded;
          in
          {
            # https://motd.gg/
            motd = "§r                    §b§lmc-test.faupi.net§r\\n${versionLine}";
            server-port = internalPort;
            spawn-protection = 0;
            max-tick-time = 5 * 60 * 1000;
            allow-flight = true;
            difficulty = "easy";
            pvp = true;
            view-distance = 16;
            gamemode = "creative";
            level-name = "piss";
            # level-type = "flat";
            # fuck you mojang give us normal documentation
            # generator-settings = "minecraft\\:bedrock,59*minecraft\\:stone,3*minecraft\\:dirt,minecraft\\:grass_block;minecraft\\:plains"; # Overworld 
          };

        jvmOpts = concatStringsSep " " [
          "-Xmx4G" # Max RAM
          "-Xms2G" # Initial RAM
          "-XX:+UseG1GC"
          "-XX:+ParallelRefProcEnabled"
          "-XX:MaxGCPauseMillis=200"
          "-XX:+UnlockExperimentalVMOptions"
          "-XX:+DisableExplicitGC"
          "-XX:+AlwaysPreTouch"
          "-XX:G1NewSizePercent=40"
          "-XX:G1MaxNewSizePercent=50"
          "-XX:G1HeapRegionSize=16M"
          "-XX:G1ReservePercent=15"
          "-XX:G1HeapWastePercent=5"
          "-XX:G1MixedGCCountTarget=4"
          "-XX:InitiatingHeapOccupancyPercent=20"
          "-XX:G1MixedGCLiveThresholdPercent=90"
          "-XX:G1RSetUpdatingPauseTimePercent=5"
          "-XX:SurvivorRatio=32"
          "-XX:+PerfDisableSharedMem"
          "-XX:MaxTenuringThreshold=1"
        ];
      };

      system.activationScripts.linkServerData = ''
        ln -sf ${../minecraft-server/server-icon.png} ${dataDir}/server-icon.png
        ln -sf ${opsFile} ${dataDir}/ops.json
        
        cp -rf ${modsRepo}/config/* ${dataDir}/config/
        find ${dataDir}/config -type f -exec chmod 660 {} \;
        find ${dataDir}/config -type d -exec chmod 770 {} \;
        chown -R minecraft:minecraft ${dataDir}/config

        mkdir -p ${dataDir}/mods
        rm -rf ${dataDir}/mods/*
        ln -sf ${modsRepo}/mods/*.jar ${dataDir}/mods/

        ${
          # Handle blacklisted mods by removing their links
          concatStringsSep "\n" (map (blacklistedMod: ''
            rm -f ${dataDir}/mods/${blacklistedMod}*.jar
          '') 
          modBlacklist)
        }
      '';

      environment.etc."resolv.conf".text = "nameserver 8.8.8.8";

      system.stateVersion = "23.11";
    };
  };
}
