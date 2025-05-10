# TODO: Resolve it always launching on the wrong screen - window rules can't affect it for some reason

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

    # TODO: Check out https://github.com/lHumaNl/EchoWarp for a possible replacement
    moonlight-mic-wrapper-script = pkgs.writeShellScript "moonlight-mic-wrapper" ''
      trap 'kill %1' SIGINT
      pw-cli -m load-module libpipewire-module-vban-send destination.ip="$(${lib.getExe pkgs.dig} +short faupi-pc.local)" destination.port=6980 sess.name="Moonlight" sess.media="audio" & 
      ${moonlightStreamCommand}
    '';

    moonlight-mic-wrapper = pkgs.makeDesktopItem (moonlightDesktopTemplate // {
      name = "${moonlightDesktopTemplate.name}_MIC";
      exec = toString moonlight-mic-wrapper-script;
      desktopName = "${moonlightDesktopTemplate.desktopName} - MIC";
    });
  in
  [
    moonlight-qt
    moonlight-mic-wrapper
    moonlight-stream-shortcut
  ];
}
