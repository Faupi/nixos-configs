# TODO: I swear to god rework this into a module or I'll cry
{ config, pkgs, lib, ... }:
with lib;
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
  legion-go-theme-config = generators.toJSON { } {
    active = true;
    "Apply" = "Xbox/Legion Go";
    "L is Select" = "No";
    "L is Start" = "No";
  };
in
{
  system.activationScripts.installDeckyPlugins = ''
    # HHD CONFIG BINDING WORKAROUND
    # NOTE: Decky needs to be root, hhd is set up under the actual user -> configs need to be linked
    mkdir -p "/home/root/.config"
    ln -snf "/home/${mainUser}/.config/hhd" "/home/${config.jovian.decky-loader.user}/.config/hhd"

    # PLUGINS
    ln -snf "${hhd-decky}" "${pluginPath}/hhd-decky"

    # THEMES
    cp -Tarf "${legion-go-theme}" "${themesPath}/legion-go"
    cp -Taf "${legion-go-theme-config}" "${themesPath}/legion-go/config_ROOT.json"
  '';
}
