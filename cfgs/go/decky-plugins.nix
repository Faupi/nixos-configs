# TODO: I swear to god rework this into a module or I'll cry
{ config, pkgs, ... }:
let
  dataPath = config.jovian.decky-loader.stateDir;

  pluginPath = "${dataPath}/plugins";
  hhd-decky = pkgs.fetchzip {
    url = "https://github.com/hhd-dev/hhd-decky/releases/download/v0.1.0/hhd-decky.tar.gz";
    sha256 = "sha256:15gpll079gwnx21gjf6qivb36dzpnrx58dkbpk0xnjjx2q0bcc47";
    stripRoot = false;
  };

  themesPath = "${dataPath}/themes";
  # TODO: Add CSS loader here too
  legion-go-theme = pkgs.fetchFromGitHub {
    owner = "frazse";
    repo = "SBP-Legion-Go-Theme";
    rev = "bcf7333bad802846fb4e61fed8e70d6e13e8112d";
    sha256 = "sha256-/uQNmg+bzCWL+NDzNEB/CNcBdknGnYa4aGZXqWX9KrU=";
  };
in
{
  system.activationScripts.installDeckyPlugins = ''
    ln -snf "${hhd-decky}" "${pluginPath}/hhd-decky"

    ln -snf "${legion-go-theme}" "${themesPath}/legion-go"
  '';
}
