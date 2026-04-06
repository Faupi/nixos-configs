{ pkgs, lib, ... }:
let
  moonlightStreamCommand = "${lib.getExe pkgs.moonlight-qt} stream lynx 'Desktop (Mic)' --quit-after";

  moonlightDesktopTemplate = {
    name = "com.moonlight_stream.Moonlight-Lynx";
    comment = "Stream games from your NVIDIA GameStream-enabled PC";
    desktopName = "Moonlight (Lynx)";
    exec = moonlightStreamCommand;
    terminal = false;
    icon = "moonlight";
    type = "Application";
    categories = [ "Qt" "Game" ];
    keywords = [ "nvidia" "gamestream" "stream" ];
  };

  moonlight-mic-wrapper = pkgs.makeDesktopItem (moonlightDesktopTemplate // {
    name = "${moonlightDesktopTemplate.name}_MIC";
    exec = toString (pkgs.writeShellScript "moonlight-mic-wrapper" /*sh*/''
      trap 'kill %1' SIGINT
      pw-cli -m load-module libpipewire-module-roc-sink \
        fec.code=rs8m \
        remote.ip=192.168.0.100 \
        remote.source.port=10001 \
        remote.repair.port=10002 \
        remote.control.port=10003 \
        sink.name="ROC Network Sink" \
        sink.props="{ node.name=\"moonlight-mic-sender\" }" &
      ${moonlightStreamCommand}
    '');
    desktopName = "${moonlightDesktopTemplate.desktopName} - MIC";
  });
in
{
  home.packages = with pkgs; [
    moonlight-qt
    moonlight-mic-wrapper
  ];
}
