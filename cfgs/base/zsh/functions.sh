nixreload() {
  sudo nixos-rebuild switch --flake github:Faupi/nixos-configs --refresh --no-update-lock-file "$@"
}
