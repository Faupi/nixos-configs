{ ... }:
let
  p = 5050;
in
{
  services.mjpg-streamer = {
    enable = true;
    inputPlugin = "input_uvc.so --device /dev/video0 --resolution 1280x720 --fps 30 -wb 4000 -bk 1 -ex 1000 -gain 255 -cagc auto -sh 100";
    outputPlugin = "output_http.so -w @www@ -n -p ${toString p}";
  };
  networking.firewall = {
    allowedTCPPorts = [ p ];
  };
}
