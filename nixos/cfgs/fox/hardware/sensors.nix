{ pkgs, ... }: {
  hardware.sensor.iio.enable = true;
  environment.systemPackages = with pkgs; [
    lm_sensors
    iio-sensor-proxy
  ];
}
