nixreload() {
  if [[ "$#" -lt 1 ]]; then
    echo "Usage: $0 <operation> [options...]"
    return
  fi
  action="$1"
  shift 1
  sudo nixos-rebuild $action --flake github:Faupi/nixos-configs --refresh --no-update-lock-file "$@"
}
nomreload() {
  if [[ "$#" -lt 1 ]]; then
    echo "Usage: $0 <operation> [options...]"
    return
  fi
  action="$1"
  shift 1
  sudo nixos-rebuild $action --flake github:Faupi/nixos-configs --refresh --no-update-lock-file "$@" --verbose --log-format internal-json |& nom --json
}

homereload() {
  if [[ "$#" -lt 1 ]]; then
    echo "Usage: $0 <operation> [options...]"
    return
  fi
  action="$1"
  shift 1
  home-manager $action --flake github:Faupi/nixos-configs --refresh -b backup --option eval-cache false "$@"
}

json2nix() {
  if [[ "$#" -lt 1 ]]; then
    echo "Usage: $0 <path>"
    return
  fi
  file="$1"
  shift 1
  nix eval --impure --expr "builtins.fromJSON (builtins.readFile \"$file\")"
}
