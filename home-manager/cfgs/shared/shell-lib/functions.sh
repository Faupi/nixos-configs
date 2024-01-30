nixreload() {
  sudo nixos-rebuild switch --flake github:Faupi/nixos-configs --refresh --no-update-lock-file "$@"
}
homereload() {
  home-manager switch --flake github:Faupi/nixos-configs --refresh -b backup --option eval-cache false "$@"
}
