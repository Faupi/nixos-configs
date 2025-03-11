{ pkgs, ... }: {
  hardware.sensor.iio.enable = true;
  environment.systemPackages = with pkgs; [
    iio-sensor-proxy
  ];
}
