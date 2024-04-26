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
    owner = "victor-borges";
    repo = "SBP-Legion-Go-Theme";
    rev = "27ce1452ef45cc12adea5eb1a83265c98859b66d";
    sha256 = "108ixzyi8y85ggvdians70mbxa2zxdv8ra9aql9lbvms5lkg33f7";
  };
  legion-go-theme-config = pkgs.writeText "css-lego-config.json" (
    generators.toJSON { } {
      active = true;
      "Apply" = "Xbox/Legion Go";
      "L is Select" = "No";
      "L is Start" = "No";
      "Legion Logo" = "Yes";
    }
  );
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
    cp -Tarf "${legion-go-theme}" "${themesPath}/legion-go/config_ROOT.json"
    cp -Taf "${legion-go-theme-config}" "${themesPath}/legion-go/config_ROOT.json"
    chown ${mainUser} -hR "${themesPath}"
  '';
}
