{ pkgs, ... }: {
  home.packages = with pkgs; let
    moonlightStreamCommand = "${lib.getExe pkgs.moonlight-qt} stream Faupi-PC Desktop --quit-after";
    moonlightDesktopTemplate = {
      name = "com.moonlight_stream.Moonlight-Faupi-PC";
      comment = "Stream games from your NVIDIA GameStream-enabled PC";
      desktopName = "Moonlight (Faupi-PC)";
      exec = moonlightStreamCommand;
      terminal = false;
      icon = "moonlight";
      type = "Application";
      categories = [ "Qt" "Game" ];
      keywords = [ "nvidia" "gamestream" "stream" ];
    };

    moonlight-stream-shortcut = pkgs.makeDesktopItem moonlightDesktopTemplate;

    # TODO: Why is this here (check https://github.com/lHumaNl/EchoWarp)
    moonlight-mic-wrapper-script = pkgs.writeShellScript "moonlight-mic-wrapper" ''
      trap 'kill %1' SIGINT
      pw-cli -m load-module libpipewire-module-vban-send local.ifname="enp4s0f3u1u4c2" destination.ip="$(${lib.getExe pkgs.dig} +short faupi-pc.local)" destination.port=6980 sess.name="Deck" sess.media="audio" & 
      ${moonlightStreamCommand}
    '';

    moonlight-mic-wrapper = pkgs.makeDesktopItem (moonlightDesktopTemplate // {
      name = "com.moonlight_stream.Moonlight-Faupi-PC_MIC";
      exec = toString moonlight-mic-wrapper-script;
      desktopName = "Moonlight (Faupi-PC) - MIC";
    });
  in
  [
    moonlight-qt
    moonlight-mic-wrapper
    moonlight-stream-shortcut
  ];
}
