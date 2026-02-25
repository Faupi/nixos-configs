{ ... }:
{
  dconf.settings = {
    "org/gnome/shell/extensions/caffeine" = {
      cli-toggle = true;
      countdown-timer = 0;
      duration-timer = 2;
      duration-timer-list = [ 900 1800 3600 ];
      enable-mpris = true;
      indicator-position-max = 3;
      nightlight-control = "never";
      show-indicator = "only-active";
      user-enabled = true;
    };
  };
}
