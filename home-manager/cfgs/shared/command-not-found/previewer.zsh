package=$1

fullJson=$(nix-env -qaA "nixpkgs.$package" --json --meta 2>/dev/null | cat)
# TODO: Gather info into an object and format better
info=$(echo "$fullJson" | tr '\r\n' ' ' | jq -Cr ".\"nixpkgs.$package\" | (.pname + \" v\" + .version + \"\n\" + .meta.description + \"\\n\\n\" + .meta.homepage)")

echo "$info"
