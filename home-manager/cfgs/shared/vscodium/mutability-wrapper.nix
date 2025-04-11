# Make user configurations mutable
# Depends on home-manager/modules/mutability.nix
# https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa

{ config, pkgs, lib, ... }:
let
  # Path logic from:
  # https://github.com/nix-community/home-manager/blob/3876cc613ac3983078964ffb5a0c01d00028139e/modules/programs/vscode.nix
  cfg = config.programs.vscode;

  vscodePname = cfg.package.pname;

  configDir = {
    "vscode" = "Code";
    "vscode-insiders" = "Code - Insiders";
    "vscodium" = "VSCodium";
  }.${vscodePname};

  userDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/${configDir}/User"
    else
      "${config.xdg.configHome}/${configDir}/User";

  configFilePath = "${userDir}/settings.json";
  tasksFilePath = "${userDir}/tasks.json";
  keybindingsFilePath = "${userDir}/keybindings.json";

  snippetDir = "${userDir}/snippets";

  pathsToMakeWritable = lib.flatten [
    (lib.optional (cfg.profiles.default.userTasks != { }) tasksFilePath)
    (lib.optional (cfg.profiles.default.userSettings != { }) configFilePath)
    (lib.optional (cfg.profiles.default.keybindings != [ ]) keybindingsFilePath)
    (lib.optional (cfg.profiles.default.globalSnippets != { })
      "${snippetDir}/global.code-snippets")
    (lib.mapAttrsToList (language: _: "${snippetDir}/${language}.json")
      cfg.profiles.default.languageSnippets)
  ];
in
{
  home.file = lib.genAttrs pathsToMakeWritable (_: {
    force = true;
    mutable = true;
  });
}
