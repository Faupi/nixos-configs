# TODO: I swear to god rework this into a module or I'll cry
{ config, pkgs, ... }:
let
  mainUser = "faupi";
  dataPath = config.jovian.decky-loader.stateDir;

  pluginPath = "${dataPath}/plugins";
  hhd-decky = fetchTarball {
    url = "https://github.com/hhd-dev/hhd-decky/releases/download/v0.1.0/hhd-decky.tar.gz";
    sha256 = "15gpll079gwnx21gjf6qivb36dzpnrx58dkbpk0xnjjx2q0bcc47";
  };

  themesPath = "${dataPath}/themes";
  # TODO: Add CSS loader here too
  legion-go-theme = pkgs.fetchFromGitHub {
    owner = "frazse";
    repo = "SBP-Legion-Go-Theme";
    rev = "bcf7333bad802846fb4e61fed8e70d6e13e8112d";
    sha256 = "1d9azmjsjmv6d2w8d7f695v03mq8gx039wyhz25jbk4v1yd0vr7y";
  };
in
{
  system.activationScripts.installDeckyPlugins = ''
    ln -snf "${hhd-decky}" "${pluginPath}/hhd-decky"
    mkdir -p "/home/root/.config"
    ln -snf "/home/${mainUser}/.config/hhd" "/home/${config.jovian.decky-loader.user}/.config/hhd"

    cp -Tarf "${legion-go-theme}" "${themesPath}/legion-go"
  '';
}
