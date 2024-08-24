{ ... }:
let
  p = 5050;
in
{
  services.mjpg-streamer = {
    enable = true;
    inputPlugin = "input_uvc.so --device /dev/video0 --resolution 1280x720 --fps 30";
    outputPlugin = "output_http.so -w @www@ -p ${toString p}";
  };
  networking.firewall = {
    allowedTCPPorts = [ p ];
  };
}
