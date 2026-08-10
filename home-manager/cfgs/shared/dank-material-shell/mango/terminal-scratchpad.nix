# TODO: Skip the DMS dock for the scratch terminal. Currently shows up in it as a valid window.

{ lib, pkgs, ... }:
let
  inherit (lib) getExe;
in
{
  wayland.windowManager.mango.settings = {
    windowrule = [
      "isnamedscratchpad:1,width:0.9,height:0.8,appid:scratchpad-terminal"
    ];
    bind = [
      "SUPER,grave,toggle_named_scratchpad,scratchpad-terminal,none,${getExe pkgs.kitty} --app-id=scratchpad-terminal"
    ];
  };
}
