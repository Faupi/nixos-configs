{ pkgs, ... }: {
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  home-manager.users.faupi = {
    home.packages = [
      pkgs.qpwgraph
    ];
    home.file.".config/pipewire/pipewire.conf.d/deck-vban.conf".source = ./pipewire-vban.conf;
  };
}
