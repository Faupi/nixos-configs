{ lib, pkgs, ... }:
let
  inherit (lib) getExe;
in
{
  wayland.windowManager.mango.settings = {
    windowrule = [
      "appid:^scratchpad-terminal$,isnamedscratchpad:1,width:0.9,height:0.8"
    ];
    bind = [
      "SUPER,grave,toggle_named_scratchpad,scratchpad-terminal,none,${getExe pkgs.kitty} --app-id=scratchpad-terminal"
    ];
  };
}
