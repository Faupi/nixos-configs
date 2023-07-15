{ config, pkgs, lib, ... }: {
  programs._1password-gui = {
    enable = true;
  }
}
