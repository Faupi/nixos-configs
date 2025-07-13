#!@bash@/bin/bash

# Loop over all arguments until we hit “--”
while [[ $# -gt 0 ]]; do
  case "$1" in
  --)
    shift # drop the “--” itself and break out
    break
    ;;
  *)
    shift # discard any argument before “--”
    ;;
  esac
done

# If nothing is left, complain
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [ignored_args…] -- command [args…]" >&2
  exit 1
fi

# Replace this script with whatever comes after “--”
exec "$@"
