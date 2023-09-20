{ dataPath ? "vintagestory", ... }: 
{
  ConfigVersion = "1.5";

  Ip = null;  # Seems to work just fine
  Port = 42420;  # Default
  Password = null;  # Whitelist
  
  ServerName = "Gamer realm";
  ServerDescription = "Buy premium for 1.99 ShitCoins";
  ServerUrl = null;
  WelcomeMessage = "wuz poppin {0}";
  ServerLanguage = "en";
  VerifyPlayerAuth = true;

  AdvertiseServer = false;
  MasterserverUrl = "http://masterserver.vintagestory.at/api/v1/servers/";

  OnlyWhitelisted = true;

  StartupCommands = ''
    /player Faupi whitelist on
    /player KudoTheYeen whitelist on
    /op Faupi
    /op KudoTheYeen
  '';

  AllowFallingBlocks = true;
  AllowFireSpread = true;
  AllowPvP = true;

  AnalyzeMode = false;
  EntityDebugMode = false;
  HostedMode = false;
  RepairMode = false;

  AntiAbuse = 0;
  BlockTickChunkRange = 4;
  BlockTickInterval = 300;
  ChatRateLimitMs = 1000;
  ClientConnectionTimeout = 150;
  CompressPackets = true;
  CorruptionProtection = true;
  DefaultRoleCode = "suplayer";
  DefaultSpawn = null;
  DieBelowDiskSpaceMb = 400;
  GroupChatHistorySize = 20;
  MapSizeX = 1024000;
  MapSizeY = 256;
  MapSizeZ = 1024000;
  MaxChunkRadius = 12;
  MaxClients = 16;
  MaxMainThreadBlockTicks = 10000;
  MaxOwnedGroupChannelsPerUser = 10;
  ModDbUrl = "https://mods.vintagestory.at/";
  ModIdBlackList = null;
  ModPaths = [ "Mods" ];  # Passed through argument
  NextPlayerGroupUid = 10;
  PassTimeWhenEmpty = false;
  RandomBlockTicksPerChunk = 16;
  RegenerateCorruptChunks = false;
  Roles = [
    {
      AutoGrant = false;
      Code = "suvisitor";
      Color = "Green";
      DefaultGameMode = 1;
      DefaultSpawn = null;
      Description =
        "Can only visit this world and chat but not use/place/break anything";
      ForcedSpawn = null;
      LandClaimAllowance = 0;
      LandClaimMaxAreas = 3;
      LandClaimMinSize = {
        X = 5;
        Y = 5;
        Z = 5;
      };
      Name = "Survival Visitor";
      PrivilegeLevel = -1;
      Privileges = [ "chat" ];
      RuntimePrivileges = [ ];
    }
    {
      AutoGrant = false;
      Code = "crvisitor";
      Color = "DarkGray";
      DefaultGameMode = 2;
      DefaultSpawn = null;
      Description =
        "Can only visit this world, chat and fly but not use/place/break anything";
      ForcedSpawn = null;
      LandClaimAllowance = 0;
      LandClaimMaxAreas = 3;
      LandClaimMinSize = {
        X = 5;
        Y = 5;
        Z = 5;
      };
      Name = "Creative Visitor";
      PrivilegeLevel = -1;
      Privileges = [ "chat" ];
      RuntimePrivileges = [ ];
    }
    {
      AutoGrant = false;
      Code = "limitedsuplayer";
      Color = "White";
      DefaultGameMode = 1;
      DefaultSpawn = null;
      Description =
        "Can use/place/break blocks only in permitted areas (priv level -1), create/manage player groups and chat";
      ForcedSpawn = null;
      LandClaimAllowance = 0;
      LandClaimMaxAreas = 3;
      LandClaimMinSize = {
        X = 5;
        Y = 5;
        Z = 5;
      };
      Name = "Limited Survival Player";
      PrivilegeLevel = -1;
      Privileges = [
        "controlplayergroups"
        "manageplayergroups"
        "chat"
        "build"
        "useblock"
        "attackcreatures"
        "attackplayers"
        "selfkill"
      ];
      RuntimePrivileges = [ ];
    }
    {
      AutoGrant = false;
      Code = "limitedcrplayer";
      Color = "LightGreen";
      DefaultGameMode = 2;
      DefaultSpawn = null;
      Description =
        "Can use/place/break blocks in only in permitted areas (priv level -1), create/manage player groups, chat, fly and set his own game mode (= allows fly and change of move speed)";
      ForcedSpawn = null;
      LandClaimAllowance = 0;
      LandClaimMaxAreas = 3;
      LandClaimMinSize = {
        X = 5;
        Y = 5;
        Z = 5;
      };
      Name = "Limited Creative Player";
      PrivilegeLevel = -1;
      Privileges = [
        "controlplayergroups"
        "manageplayergroups"
        "chat"
        "build"
        "useblock"
        "gamemode"
        "freemove"
        "attackcreatures"
        "attackplayers"
        "selfkill"
      ];
      RuntimePrivileges = [ ];
    }
    {
      AutoGrant = false;
      Code = "suplayer";
      Color = "White";
      DefaultGameMode = 1;
      DefaultSpawn = null;
      Description =
        "Can use/place/break blocks in unprotected areas (priv level 0), create/manage player groups and chat. Can claim an area of up to 8 chunks.";
      ForcedSpawn = null;
      LandClaimAllowance = 262144;
      LandClaimMaxAreas = 3;
      LandClaimMinSize = {
        X = 5;
        Y = 5;
        Z = 5;
      };
      Name = "Survival Player";
      PrivilegeLevel = 0;
      Privileges = [
        "controlplayergroups"
        "manageplayergroups"
        "chat"
        "areamodify"
        "build"
        "useblock"
        "attackcreatures"
        "attackplayers"
        "selfkill"
      ];
      RuntimePrivileges = [ ];
    }
    {
      AutoGrant = false;
      Code = "crplayer";
      Color = "LightGreen";
      DefaultGameMode = 2;
      DefaultSpawn = null;
      Description =
        "Can use/place/break blocks in all areas (priv level 100), create/manage player groups, chat, fly and set his own game mode (= allows fly and change of move speed). Can claim an area of up to 40 chunks.";
      ForcedSpawn = null;
      LandClaimAllowance = 1310720;
      LandClaimMaxAreas = 6;
      LandClaimMinSize = {
        X = 5;
        Y = 5;
        Z = 5;
      };
      Name = "Creative Player";
      PrivilegeLevel = 100;
      Privileges = [
        "controlplayergroups"
        "manageplayergroups"
        "chat"
        "areamodify"
        "build"
        "useblock"
        "gamemode"
        "freemove"
        "attackcreatures"
        "attackplayers"
        "selfkill"
      ];
      RuntimePrivileges = [ ];
    }
    {
      AutoGrant = false;
      Code = "sumod";
      Color = "Cyan";
      DefaultGameMode = 1;
      DefaultSpawn = null;
      Description =
        "Can use/place/break blocks everywhere (priv level 200), create/manage player groups, chat, kick/ban players and do serverwide announcements. Can claim an area of up to 4 chunks.";
      ForcedSpawn = null;
      LandClaimAllowance = 1310720;
      LandClaimMaxAreas = 60;
      LandClaimMinSize = {
        X = 5;
        Y = 5;
        Z = 5;
      };
      Name = "Survival Moderator";
      PrivilegeLevel = 200;
      Privileges = [
        "controlplayergroups"
        "manageplayergroups"
        "chat"
        "areamodify"
        "build"
        "useblock"
        "buildblockseverywhere"
        "useblockseverywhere"
        "kick"
        "ban"
        "announce"
        "readlists"
        "attackcreatures"
        "attackplayers"
        "selfkill"
      ];
      RuntimePrivileges = [ ];
    }
    {
      AutoGrant = false;
      Code = "crmod";
      Color = "Cyan";
      DefaultGameMode = 2;
      DefaultSpawn = null;
      Description =
        "Can use/place/break blocks everywhere (priv level 500), create/manage player groups, chat, kick/ban players, fly and set his own or other players game modes (= allows fly and change of move speed). Can claim an area of up to 40 chunks.";
      ForcedSpawn = null;
      LandClaimAllowance = 1310720;
      LandClaimMaxAreas = 60;
      LandClaimMinSize = {
        X = 5;
        Y = 5;
        Z = 5;
      };
      Name = "Creative Moderator";
      PrivilegeLevel = 500;
      Privileges = [
        "controlplayergroups"
        "manageplayergroups"
        "chat"
        "areamodify"
        "build"
        "useblock"
        "buildblockseverywhere"
        "useblockseverywhere"
        "kick"
        "ban"
        "gamemode"
        "freemove"
        "commandplayer"
        "announce"
        "readlists"
        "attackcreatures"
        "attackplayers"
        "selfkill"
      ];
      RuntimePrivileges = [ ];
    }
    {
      AutoGrant = true;
      Code = "admin";
      Color = "LightBlue";
      DefaultGameMode = 1;
      DefaultSpawn = null;
      Description =
        "Has all privileges, including giving other players admin status.";
      ForcedSpawn = null;
      LandClaimAllowance = 2147483647;
      LandClaimMaxAreas = 99999;
      LandClaimMinSize = {
        X = 5;
        Y = 5;
        Z = 5;
      };
      Name = "Admin";
      PrivilegeLevel = 99999;
      Privileges = [
        "build"
        "useblock"
        "buildblockseverywhere"
        "useblockseverywhere"
        "attackplayers"
        "attackcreatures"
        "freemove"
        "gamemode"
        "pickingrange"
        "chat"
        "kick"
        "ban"
        "whitelist"
        "setwelcome"
        "announce"
        "readlists"
        "give"
        "areamodify"
        "setspawn"
        "controlserver"
        "tp"
        "time"
        "grantrevoke"
        "root"
        "commandplayer"
        "controlplayergroups"
        "manageplayergroups"
        "selfkill"
      ];
      RuntimePrivileges = [ ];
    }
  ];
  SkipEveryChunkRow = 0;
  SkipEveryChunkRowWidth = 0;
  SpawnCapPlayerScaling = 0.75;
  TickTime = 33.3333;
  Upnp = false;
  WorldConfig = {
    AllowCreativeMode = true;
    CreatedByPlayerName = null;
    DisabledMods = null;
    MapSizeY = null;
    PlayStyle = "surviveandbuild";
    PlayStyleLangCode = "surviveandbuild-bands";
    RepairMode = false;
    SaveFileLocation = "${dataPath}/Saves/default.vcdbs";
    Seed = null;
    WorldConfiguration = null;
    WorldName = "A new world";
    WorldType = "standard";
  };
}
